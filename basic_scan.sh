#!/usr/bin/env bash
# pro_recon.sh
# Combined: user-friendly live recon + accurate nmap/fallback scanning, non-root.
# Usage: bash ./pro_recon.sh [--ports 22,80,443,...] [--timeout 1] [--retries 3] [--out report.json] [--watch 60] [--use-nmap-only]
# Note: No sudo required. For raw SYN scans or OS fingerprinting, run sudo nmap manually.

set -eo pipefail

### ---------- DEFAULTS ----------
HOST="127.0.0.1"
DEFAULT_PORTS=(21 22 23 25 53 67 68 80 110 123 137 139 143 161 443 445 587 3306 3389 8080)
PORTS=("${DEFAULT_PORTS[@]}")
TIMEOUT=1            # seconds per attempt (increase for accuracy)
RETRIES=3
PARALLEL=40          # concurrency for fallback xargs
OUTFILE=""
USE_NMAP_ONLY=0
WATCH_INTERVAL=0     # if >0, re-run main scan every N seconds and show diffs

### ---------- UI / Helpers ----------
ts() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }
shortts() { date -u +"%H:%M:%S"; }

ESC="$(printf '\033')"
RESET="${ESC}[0m"
BOLD="${ESC}[1m"
GREEN="${ESC}[32m"
YELLOW="${ESC}[33m"
RED="${ESC}[31m"
CYAN="${ESC}[36m"

title() { printf "\n${BOLD}${CYAN}===== %s | %s =====${RESET}\n" "$1" "$(ts)"; }
info()  { printf "${YELLOW}* %s${RESET}\n" "$1"; }
ok()    { printf "${GREEN}✔ %s${RESET}\n" "$1"; }
fail()  { printf "${RED}✖ %s${RESET}\n" "$1"; }

TMP_DIR="/tmp/pro_recon_$$"
mkdir -p "$TMP_DIR"
TMP_PORT_FILE="${TMP_DIR}/ports"
TMP_OPEN="${TMP_DIR}/open"
TMP_PREV_OPEN="${TMP_DIR}/prev_open"

cleanup() { rm -rf "$TMP_DIR" 2>/dev/null || true; }
trap cleanup EXIT

### ---------- ARG PARSING ----------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --ports)
      if [[ -n "${2-}" ]]; then IFS=',' read -ra arr <<< "$2"; PORTS=("${arr[@]}"); shift 2; else echo "Missing --ports arg"; exit 1; fi ;;
    --timeout) TIMEOUT="$2"; shift 2 ;;
    --retries) RETRIES="$2"; shift 2 ;;
    --out) OUTFILE="$2"; shift 2 ;;
    --use-nmap-only) USE_NMAP_ONLY=1; shift ;;
    --watch) WATCH_INTERVAL="$2"; shift 2 ;;
    -h|--help)
      cat <<EOF
Usage: $0 [--ports 22,80,443] [--timeout 1] [--retries 3] [--out report.json] [--watch 60] [--use-nmap-only]
  - Non-root tool: does not request sudo.
  - For raw SYN or OS fingerprinting: run sudo nmap -sS -O -p- <target>.
EOF
      exit 0 ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

printf "%s\n" "${PORTS[@]}" > "$TMP_PORT_FILE"

### ---------- CAPABILITY BANNER ----------
cap_banner() {
  title "OPERATIONAL SUMMARY"
  echo "User: $(whoami) | Host: ${HOST}"
  echo "Mode: Non-root | Timeout:${TIMEOUT}s | Retries:${RETRIES} | Concurrency:${PARALLEL}"
  echo "Essential ports: ${#PORTS[@]} (override with --ports)"
  if [[ "$WATCH_INTERVAL" -gt 0 ]]; then echo "Watch mode: every ${WATCH_INTERVAL}s"; fi
}

### ---------- SYSTEM INFO SECTIONS ----------
section_host() {
  title "HOST & OS"
  printf "Hostname: %s\n" "$(hostname 2>/dev/null || echo unknown)"
  printf "Kernel/OS: %s\n" "$(uname -mrs 2>/dev/null || echo unknown)"
  if command -v lsb_release >/dev/null 2>&1; then lsb_release -a 2>/dev/null | sed 's/^/  /'; fi
}

section_hw() {
  title "HARDWARE SNAPSHOT"
  if [[ -r /proc/cpuinfo ]]; then awk -F: '/model name/ {print "CPU:" substr($2,2); exit}' /proc/cpuinfo 2>/dev/null || true; else lscpu 2>/dev/null | sed -n 's/Model name:[[:space:]]*//p'; fi
  printf "Logical CPUs: %s\n" "$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo unknown)"
  awk '/MemTotal/ {printf "Memory: %s kB\n", $2}' /proc/meminfo 2>/dev/null || true
  if command -v lsblk >/dev/null 2>&1; then echo "Disks:"; lsblk -o NAME,SIZE,TYPE,MOUNTPOINT 2>/dev/null | sed 's/^/  /'; fi
}

section_network() {
  title "NETWORK"
  if command -v ip >/dev/null 2>&1; then
    echo "IP Addresses:"
    ip -4 addr show scope global 2>/dev/null | awk '/inet /{print "  - "$2}'
    echo "Routes:"; ip route 2>/dev/null | sed 's/^/  /'
  else
    if command -v ifconfig >/dev/null 2>&1; then ifconfig 2>/dev/null | sed 's/^/  /'; else echo "  (ip/ifconfig missing)"; fi
  fi
}

section_users() {
  title "USERS"
  echo "Logged in users:"; who 2>/dev/null | sed 's/^/  - /' || echo "  - (who not available)"
  echo "Recent logins (last 5):"; last -n 5 2>/dev/null | sed 's/^/  /' || true
  echo "Local accounts (sample):"; cut -d: -f1 /etc/passwd | head -n 50 | sed 's/^/  - /'
}

section_services() {
  title "SERVICES (non-root view)"
  if command -v systemctl >/dev/null 2>&1; then
    echo "Active services (sample):"
    systemctl list-units --type=service --state=running --no-pager 2>/dev/null | sed -n '1,40p' | sed 's/^/  /'
  elif command -v service >/dev/null 2>&1; then
    echo "Service status (sysv sample):"
    service --status-all 2>/dev/null | sed 's/^/  /' | head -n 40
  else
    echo "  (systemctl/service not available)"
  fi
}

section_installed() {
  title "INSTALLED SOFTWARE (SAMPLES)"
  if command -v dpkg >/dev/null 2>&1; then dpkg -l 2>/dev/null | sed -n '6,25p' | sed 's/^/  /'; 
  elif command -v rpm >/dev/null 2>&1; then rpm -qa 2>/dev/null | head -n 20 | sed 's/^/  /'; 
  elif command -v pacman >/dev/null 2>&1; then pacman -Q 2>/dev/null | head -n 20 | sed 's/^/  /';
  else echo "  (package manager not detected)"; fi

  if command -v pip3 >/dev/null 2>&1; then echo "Python pip3 (user) sample:"; pip3 list --user 2>/dev/null | sed 's/^/  /' | head -n 20; fi
  if command -v snap >/dev/null 2>&1; then echo "snap sample:"; snap list 2>/dev/null | sed 's/^/  /' | head -n 10; fi
  if command -v flatpak >/dev/null 2>&1; then echo "flatpak sample:"; flatpak list 2>/dev/null | sed 's/^/  /' | head -n 10; fi
}

### ---------- PORT SCANNING (nmap preferred, fallback accurate method) ----------
NMAP_BIN="$(command -v nmap 2>/dev/null || true)"

run_nmap_scan() {
  local ports_csv; ports_csv=$(IFS=, ; echo "${PORTS[*]}")
  title "NMAP SCAN (non-root: connect + version detect)"
  info "Running: nmap -sT -sV --version-light -Pn --reason -p ${ports_csv} ${HOST}"
  # produce XML then parse to live lines
  local xmltmp="${TMP_DIR}/nmap.xml"
  if ! nmap -sT -sV --version-light -Pn --reason -p "${ports_csv}" "${HOST}" -oX "${xmltmp}" >/dev/null 2>&1; then
    fail "nmap reported errors (non-fatal)."
    return 1
  fi
  awk '
    /<port / { p=gensub(/^.*portid="([0-9]+)".*$/,"\\1","g") }
    /<state / && /state="/ { match($0,/state="([^"]+)"/,s); st=s[1] }
    /<service / { match($0,/name="([^"]+)"/,n); svc=n[1] }
    /<\/port>/ {
      if (p=="") next
      # Note: prod, ver, reason intentionally omitted from output per request
      printf "%s [PORT %s] %s svc=%s\n", "'"$(shortts)"'", p, (st?st:"unknown"), (svc?svc:"unknown")
      p=""; st=""; svc=""
    }
  ' "${xmltmp}" | while IFS= read -r ln; do
    if [[ "$ln" =~ "open" ]]; then
      printf "${GREEN}%s${RESET}\n" "$ln"
      echo "$ln" >> "$TMP_OPEN"
    else
      printf "%s\n" "$ln"
    fi
  done
  return 0
}

fallback_scan_port() {
  local port="$1"
  local attempt open=0 i banner svcname
  for ((i=1;i<=RETRIES;i++)); do
    if bash -c ">/dev/tcp/${HOST}/${port}" >/dev/null 2>&1; then open=1; break; fi
    if command -v nc >/dev/null 2>&1; then
      if nc -z -w "$TIMEOUT" "$HOST" "$port" >/dev/null 2>&1; then open=1; break; fi
    fi
    sleep 0.1
  done

  if (( open )); then
    # banner grab
    if command -v nc >/dev/null 2>&1; then
      banner=$( (printf "\r\n"; sleep 0.15) | nc "$HOST" "$port" -w "$TIMEOUT" 2>/dev/null | sed -n '1,4p' | tr '\n' ' ' | sed 's/"/\\"/g' )
    fi
    if [[ -z "$banner" ]] && { [[ "$port" == "80" ]] || [[ "$port" == "8080" ]] || [[ "$port" == "443" ]]; } && command -v curl >/dev/null 2>&1; then
      banner=$(curl -I --max-time "$TIMEOUT" --silent --insecure "http://${HOST}:${port}" 2>/dev/null | sed -n '1,4p' | tr '\n' ' ' | sed 's/"/\\"/g')
    fi
    if [[ -r /etc/services ]]; then svcname=$(awk -v p="$port" '$2 ~ "^"p"/tcp" {print $1; exit}' /etc/services || true); fi
    printf "%s ${GREEN}[OPEN]${RESET} Port:%s svc:%s banner:\"%s\"\n" "$(shortts)" "$port" "${svcname:-unknown}" "${banner:-no-banner}"
    # JSON-ish line for later aggregation
    printf '{"port":%s,"service":"%s","banner":"%s"}\n' "$port" "${svcname:-unknown}" "${banner//\"/\\\"}" >> "$TMP_OPEN"
  else
    printf "%s ${RED}[closed]${RESET} Port:%s\n" "$(shortts)" "$port"
  fi
}

run_fallback_scan() {
  title "FALLBACK SCAN (connect + banner grab)"
  info "Retries:${RETRIES} Timeout:${TIMEOUT}s Concurrency:${PARALLEL}"
  echo
  export -f fallback_scan_port shortts
  export HOST TIMEOUT RETRIES TMP_OPEN
  cat "$TMP_PORT_FILE" | xargs -n1 -P "$PARALLEL" -I{} bash -c 'fallback_scan_port "{}"' _ {}
}


### ---------- MAIN RUN (single iteration) ----------
run_one_cycle() {
  rm -f "$TMP_OPEN" 2>/dev/null || true
  cap_banner
  section_host; section_hw; section_network; section_users; section_services; section_installed

  # PORT SCAN: prefer nmap, unless user asked to skip fallback
  if [[ -n "$NMAP_BIN" && $USE_NMAP_ONLY -eq 0 ]]; then
    if run_nmap_scan; then ok "nmap complete"; else info "nmap failed or partial; running fallback"; run_fallback_scan; fi
  elif [[ -n "$NMAP_BIN" && $USE_NMAP_ONLY -eq 1 ]]; then
    if run_nmap_scan; then ok "nmap-only done"; else fail "nmap-only failed"; fi
  else
    run_fallback_scan
  fi

  # Summary and collect open ports
  title "PORT SUMMARY"
  if [[ -s "$TMP_OPEN" ]]; then
    echo "Open ports (detected):"
    # if JSON-like entries exist, print neat; else print raw lines
    if grep -q '^{' "$TMP_OPEN" 2>/dev/null; then
      while IFS= read -r jline; do
        # minimal pretty: port & service & banner
        port=$(echo "$jline" | sed -n 's/.*"port":[[:space:]]*\([0-9]*\).*/\1/p')
        svc=$(echo "$jline" | sed -n 's/.*"service":"\([^"]*\)".*/\1/p')
        banner=$(echo "$jline" | sed -n 's/.*"banner":"\([^"]*\)".*/\1/p' | sed 's/\\\"/\"/g')
        echo "  - ${port}  svc:${svc}  banner:${banner}"
      done < "$TMP_OPEN"
    else
      sed 's/^/  - /' "$TMP_OPEN"
    fi
  else
    echo "  No open essential ports detected."
  fi

  # Save JSON if requested (simple structure)
  if [[ -n "$OUTFILE" ]]; then
    title "SAVING JSON REPORT"
    {
      echo "{"
      echo "  \"collected_at\": \"$(ts)\","
      echo "  \"host\": \"${HOST}\","
      echo -n "  \"open_ports\": ["
      first=1
      if [[ -s "$TMP_OPEN" ]]; then
        while IFS= read -r line; do
          if [[ $line == \{* ]]; then
            if [[ $first -eq 0 ]]; then echo -n ","; fi
            echo -n "$line"
            first=0
          else
            # raw text line
            esc=$(printf '%s' "$line" | sed 's/"/\\"/g')
            if [[ $first -eq 0 ]]; then echo -n ","; fi
            echo -n "{\"raw\":\"${esc}\"}"
            first=0
          fi
        done < "$TMP_OPEN"
      fi
      echo "]"
      echo "}"
    } > "$OUTFILE"
    ok "Saved JSON -> ${OUTFILE}"
  fi
}

### ---------- WATCH MODE (if enabled) ----------
if [[ "$WATCH_INTERVAL" -gt 0 ]]; then
  ok "Starting watch mode; interval ${WATCH_INTERVAL}s"
  while true; do
    # rotate prev
    if [[ -f "$TMP_OPEN" ]]; then mv "$TMP_OPEN" "$TMP_PREV_OPEN" 2>/dev/null || true; else rm -f "$TMP_PREV_OPEN" 2>/dev/null || true; fi
    run_one_cycle
    # diff open lists
    if [[ -f "$TMP_PREV_OPEN" && -f "$TMP_OPEN" ]]; then
      added=$(comm -13 <(sort "$TMP_PREV_OPEN") <(sort "$TMP_OPEN") || true)
      removed=$(comm -23 <(sort "$TMP_PREV_OPEN") <(sort "$TMP_OPEN") || true)
      if [[ -n "$added" ]]; then title "CHANGES: ADDED"; printf "%s\n" "$added"; fi
      if [[ -n "$removed" ]]; then title "CHANGES: REMOVED"; printf "%s\n" "$removed"; fi
    fi
    echo; info "Next run in ${WATCH_INTERVAL}s (Ctrl-C to stop)"; sleep "$WATCH_INTERVAL"
  done
else
  run_one_cycle
  ok "Scan completed at $(ts)"
fi

exit 0
