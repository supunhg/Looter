#!/usr/bin/env bash
# Looter - Basic Scan v1.2
# Quick system enumeration: Hardware, Software, Services, Ports, Users
# Usage: bash ./basic_scan.sh [--target HOST] [--out report.txt]

set -eo pipefail

# Display tool header
clear
cat << "EOF"
╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║            ██╗      ██████╗  ██████╗ ████████╗███████╗██████╗             ║
║            ██║     ██╔═══██╗██╔═══██╗╚══██╔══╝██╔════╝██╔══██╗            ║
║            ██║     ██║   ██║██║   ██║   ██║   █████╗  ██████╔╝            ║
║            ██║     ██║   ██║██║   ██║   ██║   ██╔══╝  ██╔══██╗            ║
║            ███████╗╚██████╔╝╚██████╔╝   ██║   ███████╗██║  ██║            ║
║            ╚══════╝ ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝╚═╝  ╚═╝            ║
║                                                                           ║
║                       Network Reconnaissance Tool                         ║
║                            [ BASIC SCAN ]                                 ║
║                                                                           ║
║           Hardware | Software | Services | Ports | Users                 ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝

EOF
sleep 1

### ---------- DEFAULTS ----------
TARGET="127.0.0.1"
OUTFILE="basic_scan_$(date +%Y%m%d_%H%M%S).txt"
DEFAULT_PORTS=(21 22 23 25 53 80 110 139 143 443 445 3306 3389 5432 8080 8443)

### ---------- COLORS ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

### ---------- ARG PARSING ----------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target|-t) TARGET="$2"; shift 2 ;;
    --out|-o) OUTFILE="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 [--target HOST] [--out report.txt]"
      echo "  --target, -t    Target host/IP (default: 127.0.0.1)"
      echo "  --out, -o       Output file (default: basic_scan_TIMESTAMP.txt)"
      exit 0 ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

### ---------- HELPER FUNCTIONS ----------
print_section() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════╗${NC}" | tee -a "$OUTFILE"
    echo -e "${BLUE}║  $1${NC}" | tee -a "$OUTFILE"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}" | tee -a "$OUTFILE"
}

info() { echo -e "${CYAN}[*]${NC} $1" | tee -a "$OUTFILE"; }
success() { echo -e "${GREEN}[✓]${NC} $1" | tee -a "$OUTFILE"; }
warn() { echo -e "${YELLOW}[!]${NC} $1" | tee -a "$OUTFILE"; }
error() { echo -e "${RED}[✗]${NC} $1" | tee -a "$OUTFILE"; }

run_cmd() {
    local desc="$1"
    local cmd="$2"
    info "$desc"
    eval "$cmd" 2>&1 | tee -a "$OUTFILE"
}

command_exists() { command -v "$1" &> /dev/null; }

### ---------- START SCAN ----------
echo "═══════════════════════════════════════════════════════════════" | tee "$OUTFILE"
echo "LOOTER - BASIC SCAN" | tee -a "$OUTFILE"
echo "═══════════════════════════════════════════════════════════════" | tee -a "$OUTFILE"
echo "Scan started: $(date)" | tee -a "$OUTFILE"
echo "Target: $TARGET" | tee -a "$OUTFILE"
echo "User: $(whoami)" | tee -a "$OUTFILE"
echo "═══════════════════════════════════════════════════════════════" | tee -a "$OUTFILE"

### ---------- HOSTNAME & IP ----------
print_section "HOSTNAME & IP INFORMATION"
run_cmd "Hostname" "hostname 2>/dev/null || echo 'Unknown'"
run_cmd "FQDN" "hostname -f 2>/dev/null || echo 'Not available'"
run_cmd "IP Addresses" "ip -4 addr show 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' || ifconfig 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}'"
run_cmd "Default Gateway" "ip route | grep default | awk '{print \$3}' || route -n | grep '^0.0.0.0' | awk '{print \$2}'"
run_cmd "DNS Servers" "cat /etc/resolv.conf | grep nameserver | awk '{print \$2}'"

### ---------- HARDWARE INFORMATION ----------
print_section "HARDWARE INFORMATION"
run_cmd "System Info" "uname -a"
run_cmd "CPU Model" "lscpu | grep 'Model name' || grep 'model name' /proc/cpuinfo | head -1"
run_cmd "CPU Cores" "nproc 2>/dev/null || grep -c processor /proc/cpuinfo"
run_cmd "Total Memory" "free -h | grep Mem | awk '{print \$2}'"
run_cmd "Disk Space" "df -h | grep -E '^/dev/'"

### ---------- INSTALLED SOFTWARE WITH VERSIONS ----------
print_section "INSTALLED SOFTWARE & VERSIONS"

# Detect package manager and list software
if command_exists dpkg; then
    info "Package Manager: APT/DPKG (Debian/Ubuntu)"
    echo -e "\nInstalled Packages (Top 50):" | tee -a "$OUTFILE"
    dpkg -l 2>/dev/null | grep '^ii' | awk '{printf "%-30s %s\n", $2, $3}' | head -50 | tee -a "$OUTFILE"
    echo -e "\nTotal Packages: $(dpkg -l | grep '^ii' | wc -l)" | tee -a "$OUTFILE"
elif command_exists rpm; then
    info "Package Manager: RPM/YUM/DNF (RedHat/CentOS/Fedora)"
    echo -e "\nInstalled Packages (Top 50):" | tee -a "$OUTFILE"
    rpm -qa --qf "%-30{NAME} %{VERSION}-%{RELEASE}\n" 2>/dev/null | head -50 | tee -a "$OUTFILE"
    echo -e "\nTotal Packages: $(rpm -qa | wc -l)" | tee -a "$OUTFILE"
elif command_exists pacman; then
    info "Package Manager: Pacman (Arch Linux)"
    echo -e "\nInstalled Packages (Top 50):" | tee -a "$OUTFILE"
    pacman -Q 2>/dev/null | head -50 | tee -a "$OUTFILE"
    echo -e "\nTotal Packages: $(pacman -Q | wc -l)" | tee -a "$OUTFILE"
else
    warn "No recognized package manager found"
fi

# Key software versions
echo -e "\n${CYAN}Critical Software Versions:${NC}" | tee -a "$OUTFILE"
for software in apache2 nginx mysql postgresql sshd docker python python3 perl ruby php gcc java node; do
    case $software in
        apache2) command_exists apache2 && echo "Apache: $(apache2 -v 2>/dev/null | head -1)" | tee -a "$OUTFILE" ;;
        nginx) command_exists nginx && echo "Nginx: $(nginx -v 2>&1)" | tee -a "$OUTFILE" ;;
        mysql) command_exists mysql && echo "MySQL: $(mysql --version 2>/dev/null)" | tee -a "$OUTFILE" ;;
        postgresql) command_exists psql && echo "PostgreSQL: $(psql --version 2>/dev/null)" | tee -a "$OUTFILE" ;;
        sshd) command_exists sshd && echo "OpenSSH: $(sshd -V 2>&1 | head -1)" | tee -a "$OUTFILE" ;;
        docker) command_exists docker && echo "Docker: $(docker --version 2>/dev/null)" | tee -a "$OUTFILE" ;;
        python) command_exists python && echo "Python: $(python --version 2>&1)" | tee -a "$OUTFILE" ;;
        python3) command_exists python3 && echo "Python3: $(python3 --version 2>&1)" | tee -a "$OUTFILE" ;;
        perl) command_exists perl && echo "Perl: $(perl --version | grep 'This is perl' | head -1)" | tee -a "$OUTFILE" ;;
        ruby) command_exists ruby && echo "Ruby: $(ruby --version 2>/dev/null)" | tee -a "$OUTFILE" ;;
        php) command_exists php && echo "PHP: $(php --version 2>/dev/null | head -1)" | tee -a "$OUTFILE" ;;
        gcc) command_exists gcc && echo "GCC: $(gcc --version | head -1)" | tee -a "$OUTFILE" ;;
        java) command_exists java && echo "Java: $(java -version 2>&1 | head -1)" | tee -a "$OUTFILE" ;;
        node) command_exists node && echo "Node.js: $(node --version 2>/dev/null)" | tee -a "$OUTFILE" ;;
    esac
done

### ---------- AVAILABLE SERVICES ----------
print_section "AVAILABLE SERVICES"

info "Active Services:"
if command_exists systemctl; then
    systemctl list-units --type=service --state=running --no-pager 2>/dev/null | grep -E '\.service' | awk '{print $1}' | sed 's/.service$//' | tee -a "$OUTFILE"
elif command_exists service; then
    service --status-all 2>/dev/null | grep '\[ + \]' | awk '{print $4}' | tee -a "$OUTFILE"
else
    warn "Cannot enumerate services (systemctl/service not available)"
    ps aux | grep -E 'sshd|httpd|nginx|mysql|postgres' | grep -v grep | tee -a "$OUTFILE"
fi

info "Enabled Services:"
if command_exists systemctl; then
    systemctl list-unit-files --type=service --state=enabled --no-pager 2>/dev/null | grep -E '\.service' | awk '{print $1}' | sed 's/.service$//' | head -30 | tee -a "$OUTFILE"
fi

### ---------- USERS ----------
print_section "USER INFORMATION"
run_cmd "Current User" "whoami"
run_cmd "User ID" "id"
run_cmd "Logged In Users" "who"
run_cmd "Last Logins" "last | head -20"

echo -e "\n${CYAN}All System Users:${NC}" | tee -a "$OUTFILE"
awk -F: '$3 >= 0 {printf "%-20s UID: %-6s Shell: %s\n", $1, $3, $7}' /etc/passwd | tee -a "$OUTFILE"

echo -e "\n${CYAN}Users with Login Shells:${NC}" | tee -a "$OUTFILE"
grep -vE 'nologin|false' /etc/passwd | awk -F: '{printf "%-20s UID: %-6s Shell: %s\n", $1, $3, $7}' | tee -a "$OUTFILE"

### ---------- OPEN & FILTERED PORTS ----------
print_section "PORT SCANNING"

info "Scanning target: $TARGET"

# Function to scan ports
scan_ports() {
    local target=$1
    echo -e "\n${YELLOW}Open Ports:${NC}" | tee -a "$OUTFILE"
    
    # Try nmap first (most reliable)
    if command_exists nmap; then
        success "Using nmap for port scanning..."
        nmap -sT -Pn --open -p- --max-retries 2 -T4 "$target" 2>/dev/null | tee -a "$OUTFILE"
        
        # Service version detection
        echo -e "\n${YELLOW}Service Version Detection:${NC}" | tee -a "$OUTFILE"
        nmap -sV -Pn --version-intensity 5 -p $(echo ${DEFAULT_PORTS[@]} | tr ' ' ',') "$target" 2>/dev/null | grep -E 'open|filtered' | tee -a "$OUTFILE"
    else
        warn "nmap not found, using fallback method..."
        
        # Fallback: netcat or /dev/tcp
        for port in "${DEFAULT_PORTS[@]}"; do
            if command_exists nc; then
                if timeout 2 nc -zv "$target" "$port" 2>&1 | grep -q succeeded; then
                    echo "Port $port: OPEN" | tee -a "$OUTFILE"
                fi
            else
                # Bash TCP test
                if timeout 2 bash -c "echo >/dev/tcp/$target/$port" 2>/dev/null; then
                    echo "Port $port: OPEN" | tee -a "$OUTFILE"
                fi
            fi
        done
    fi
    
    # Local listening ports
    echo -e "\n${YELLOW}Local Listening Ports:${NC}" | tee -a "$OUTFILE"
    if command_exists ss; then
        ss -tuln | grep LISTEN | tee -a "$OUTFILE"
    elif command_exists netstat; then
        netstat -tuln | grep LISTEN | tee -a "$OUTFILE"
    else
        warn "Cannot list listening ports"
    fi
}

scan_ports "$TARGET"

### ---------- NETWORK CONNECTIONS ----------
print_section "ACTIVE NETWORK CONNECTIONS"
if command_exists ss; then
    run_cmd "Established Connections" "ss -tunp | grep ESTAB | head -20"
else
    run_cmd "Established Connections" "netstat -tunp 2>/dev/null | grep ESTABLISHED | head -20"
fi

### ---------- SUMMARY ----------
print_section "SCAN SUMMARY"
echo "Scan completed: $(date)" | tee -a "$OUTFILE"
echo "Output saved to: $OUTFILE" | tee -a "$OUTFILE"
echo "" | tee -a "$OUTFILE"
success "Basic scan complete!"
echo "" | tee -a "$OUTFILE"
echo "═══════════════════════════════════════════════════════════════" | tee -a "$OUTFILE"
echo "For more detailed analysis, run:" | tee -a "$OUTFILE"
echo "  - Intermediate Scan: ./intermediate_scan.sh" | tee -a "$OUTFILE"
echo "  - Deep Scan (Offline): ./deep_scan_offline.sh" | tee -a "$OUTFILE"
echo "  - Deep Scan (Online): ./deep_scan_online.sh" | tee -a "$OUTFILE"
echo "═══════════════════════════════════════════════════════════════" | tee -a "$OUTFILE"

exit 0
