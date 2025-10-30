#!/usr/bin/env bash
# Looter - Intermediate Scan v1.0
# Basic scan + Known vulnerability detection for outdated software
# Usage: bash ./intermediate_scan.sh [--target HOST] [--out report.txt]

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
║                     Security Assessment & Analysis                        ║
║                        [ INTERMEDIATE SCAN ]                              ║
║                                                                           ║
║      Basic Info + Known Vulnerabilities + Outdated Software Check        ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝

EOF
sleep 1

### ---------- DEFAULTS ----------
TARGET="127.0.0.1"
OUTFILE="intermediate_scan_$(date +%Y%m%d_%H%M%S).txt"
DEFAULT_PORTS=(21 22 23 25 53 80 110 139 143 443 445 3306 3389 5432 6379 8080 8443 27017)

### ---------- COLORS ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

### ---------- VULNERABILITY TRACKING ----------
VULN_COUNT=0
CRITICAL_VULN=0
HIGH_VULN=0
MEDIUM_VULN=0

### ---------- ARG PARSING ----------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target|-t) TARGET="$2"; shift 2 ;;
    --out|-o) OUTFILE="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 [--target HOST] [--out report.txt]"
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

vuln_critical() {
    echo -e "${RED}[CRITICAL]${NC} $1" | tee -a "$OUTFILE"
    CRITICAL_VULN=$((CRITICAL_VULN + 1))
    VULN_COUNT=$((VULN_COUNT + 1))
}

vuln_high() {
    echo -e "${RED}[HIGH]${NC} $1" | tee -a "$OUTFILE"
    HIGH_VULN=$((HIGH_VULN + 1))
    VULN_COUNT=$((VULN_COUNT + 1))
}

vuln_medium() {
    echo -e "${YELLOW}[MEDIUM]${NC} $1" | tee -a "$OUTFILE"
    MEDIUM_VULN=$((MEDIUM_VULN + 1))
    VULN_COUNT=$((VULN_COUNT + 1))
}

command_exists() { command -v "$1" &> /dev/null; }

# Extract version number from string
extract_version() {
    echo "$1" | grep -oP '\d+\.\d+(\.\d+)?' | head -1
}

# Compare versions (returns 0 if v1 < v2, 1 if v1 >= v2)
version_lt() {
    [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" != "$2" ]
}

### ---------- START SCAN ----------
echo "═══════════════════════════════════════════════════════════════" | tee "$OUTFILE"
echo "LOOTER - INTERMEDIATE SCAN" | tee -a "$OUTFILE"
echo "═══════════════════════════════════════════════════════════════" | tee -a "$OUTFILE"
echo "Scan started: $(date)" | tee -a "$OUTFILE"
echo "Target: $TARGET" | tee -a "$OUTFILE"
echo "═══════════════════════════════════════════════════════════════" | tee -a "$OUTFILE"

# Run all basic scan components first
source <(cat <<'BASIC_SCAN'
### HOSTNAME & IP
print_section "HOSTNAME & IP INFORMATION"
info "Hostname: $(hostname)"
info "FQDN: $(hostname -f 2>/dev/null || echo 'N/A')"
info "IP Addresses:"
ip -4 addr show 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | tee -a "$OUTFILE" || echo "Cannot detect IP"

### HARDWARE INFO
print_section "HARDWARE INFORMATION"
info "System: $(uname -a)"
info "CPU: $(lscpu | grep 'Model name' | cut -d':' -f2 | xargs || grep 'model name' /proc/cpuinfo | head -1 | cut -d':' -f2)"
info "Cores: $(nproc)"
info "Memory: $(free -h | grep Mem | awk '{print $2}')"
info "Disk: $(df -h | grep -E '^/dev/' | awk '{print $1 ": " $2 " (" $5 " used)"}')"

### SOFTWARE WITH VERSIONS
print_section "INSTALLED SOFTWARE & VERSIONS"
BASIC_SCAN
)

# Detect package manager
if command_exists dpkg; then
    PKG_MANAGER="dpkg"
    info "Package Manager: APT/DPKG"
    dpkg -l 2>/dev/null | grep '^ii' | awk '{printf "%-30s %s\n", $2, $3}' | head -30 | tee -a "$OUTFILE"
elif command_exists rpm; then
    PKG_MANAGER="rpm"
    info "Package Manager: RPM"
    rpm -qa --qf "%-30{NAME} %{VERSION}-%{RELEASE}\n" | head -30 | tee -a "$OUTFILE"
elif command_exists pacman; then
    PKG_MANAGER="pacman"
    info "Package Manager: Pacman"
    pacman -Q | head -30 | tee -a "$OUTFILE"
fi

### ---------- VULNERABILITY DETECTION ----------
print_section "VULNERABILITY DETECTION - OUTDATED SOFTWARE"

info "Checking for known vulnerable software versions..."

# Check kernel version
KERNEL_VERSION=$(uname -r | grep -oP '^\d+\.\d+')
info "Kernel version: $(uname -r)"
if version_lt "$KERNEL_VERSION" "5.10"; then
    vuln_high "Kernel version is outdated ($(uname -r)). Consider upgrading to 5.10+ or 6.x"
    info "  → Older kernels may be vulnerable to known exploits (DirtyCOW, etc.)"
fi

# Check OpenSSH version
if command_exists sshd; then
    SSH_VERSION=$(sshd -V 2>&1 | grep -oP 'OpenSSH_\K[\d.]+')
    info "OpenSSH version: $SSH_VERSION"
    if version_lt "$SSH_VERSION" "8.0"; then
        vuln_high "OpenSSH version is outdated ($SSH_VERSION < 8.0)"
        info "  → Multiple vulnerabilities fixed in newer versions"
    elif version_lt "$SSH_VERSION" "9.0"; then
        vuln_medium "OpenSSH version is moderately old ($SSH_VERSION < 9.0)"
    fi
fi

# Check Apache version
if command_exists apache2; then
    APACHE_VERSION=$(apache2 -v 2>/dev/null | grep -oP 'Apache/\K[\d.]+')
    info "Apache version: $APACHE_VERSION"
    if version_lt "$APACHE_VERSION" "2.4.50"; then
        vuln_critical "Apache version is vulnerable ($APACHE_VERSION < 2.4.50)"
        info "  → Path traversal and RCE vulnerabilities (CVE-2021-41773, CVE-2021-42013)"
    elif version_lt "$APACHE_VERSION" "2.4.54"; then
        vuln_medium "Apache version has known issues ($APACHE_VERSION < 2.4.54)"
    fi
fi

# Check Nginx version
if command_exists nginx; then
    NGINX_VERSION=$(nginx -v 2>&1 | grep -oP 'nginx/\K[\d.]+')
    info "Nginx version: $NGINX_VERSION"
    if version_lt "$NGINX_VERSION" "1.20.0"; then
        vuln_high "Nginx version is outdated ($NGINX_VERSION < 1.20.0)"
        info "  → Multiple security fixes available in newer versions"
    fi
fi

# Check MySQL/MariaDB version
if command_exists mysql; then
    MYSQL_VERSION=$(mysql --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' | head -1)
    info "MySQL/MariaDB version: $MYSQL_VERSION"
    if version_lt "$MYSQL_VERSION" "8.0.0"; then
        vuln_medium "MySQL version is old ($MYSQL_VERSION < 8.0)"
        info "  → Consider upgrading for security improvements"
    fi
fi

# Check PostgreSQL version
if command_exists psql; then
    PG_VERSION=$(psql --version | grep -oP '\d+\.\d+')
    info "PostgreSQL version: $PG_VERSION"
    if version_lt "$PG_VERSION" "14.0"; then
        vuln_medium "PostgreSQL version is moderately old ($PG_VERSION < 14.0)"
    fi
fi

# Check PHP version
if command_exists php; then
    PHP_VERSION=$(php --version | grep -oP 'PHP \K[\d.]+' | head -1)
    info "PHP version: $PHP_VERSION"
    if version_lt "$PHP_VERSION" "7.4.0"; then
        vuln_critical "PHP version is end-of-life ($PHP_VERSION < 7.4)"
        info "  → No security updates available for this version"
    elif version_lt "$PHP_VERSION" "8.0.0"; then
        vuln_high "PHP version is outdated ($PHP_VERSION < 8.0)"
    fi
fi

# Check Python version
if command_exists python3; then
    PY_VERSION=$(python3 --version | grep -oP '\d+\.\d+\.\d+')
    info "Python3 version: $PY_VERSION"
    if version_lt "$PY_VERSION" "3.7.0"; then
        vuln_high "Python3 version is end-of-life ($PY_VERSION < 3.7)"
    fi
fi

# Check Docker version
if command_exists docker; then
    DOCKER_VERSION=$(docker --version | grep -oP '\d+\.\d+\.\d+')
    info "Docker version: $DOCKER_VERSION"
    if version_lt "$DOCKER_VERSION" "20.10.0"; then
        vuln_medium "Docker version is old ($DOCKER_VERSION < 20.10)"
    fi
fi

# Check for package updates
print_section "AVAILABLE SECURITY UPDATES"
if [ "$PKG_MANAGER" = "dpkg" ]; then
    info "Checking for security updates (APT)..."
    if command_exists apt; then
        apt list --upgradable 2>/dev/null | grep -i security | head -20 | tee -a "$OUTFILE" || info "No security updates or unable to check"
    fi
elif [ "$PKG_MANAGER" = "rpm" ]; then
    info "Checking for security updates (YUM/DNF)..."
    if command_exists yum; then
        yum list updates --security 2>/dev/null | head -20 | tee -a "$OUTFILE" || info "Unable to check updates"
    fi
fi

### ---------- SERVICES ----------
print_section "AVAILABLE SERVICES"
if command_exists systemctl; then
    info "Active Services:"
    systemctl list-units --type=service --state=running --no-pager 2>/dev/null | grep -E '\.service' | awk '{print $1}' | sed 's/.service$//' | head -30 | tee -a "$OUTFILE"
fi

### ---------- USERS ----------
print_section "USER INFORMATION"
info "Current User: $(whoami) ($(id))"
info "Logged In: $(who | wc -l) users"
echo -e "\nUsers with login shells:" | tee -a "$OUTFILE"
grep -vE 'nologin|false' /etc/passwd | awk -F: '{printf "%-20s UID: %s\n", $1, $3}' | tee -a "$OUTFILE"

### ---------- PORT SCAN ----------
print_section "PORT SCANNING & SERVICE DETECTION"
info "Scanning target: $TARGET"

if command_exists nmap; then
    success "Using nmap for comprehensive scanning..."
    nmap -sV -sC -Pn --version-intensity 7 -p $(echo ${DEFAULT_PORTS[@]} | tr ' ' ',') "$TARGET" 2>/dev/null | tee -a "$OUTFILE"
else
    warn "nmap not available - install for better results"
    info "Checking common ports..."
    for port in "${DEFAULT_PORTS[@]}"; do
        timeout 2 bash -c "echo >/dev/tcp/$TARGET/$port" 2>/dev/null && echo "Port $port: OPEN" | tee -a "$OUTFILE"
    done
fi

# Check for dangerous open ports
print_section "DANGEROUS SERVICE DETECTION"
ss -tuln 2>/dev/null | grep LISTEN | while read line; do
    if echo "$line" | grep -qE ":23 |:21 |:69 |:512 |:513 "; then
        vuln_high "Insecure service detected: $(echo $line | awk '{print $5}')"
        info "  → Telnet/FTP/TFTP/rsh transmit credentials in plaintext"
    elif echo "$line" | grep -qE ":3306 |:5432 |:27017 |:6379 " | grep -q "0.0.0.0"; then
        vuln_high "Database exposed on all interfaces: $(echo $line | awk '{print $5}')"
        info "  → Databases should be bound to localhost only"
    fi
done

### ---------- CONFIGURATION ISSUES ----------
print_section "CONFIGURATION SECURITY CHECKS"

# Check SSH config
if [ -f "/etc/ssh/sshd_config" ]; then
    info "Analyzing SSH configuration..."
    if grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config 2>/dev/null; then
        vuln_high "SSH permits root login"
    fi
    if grep -q "^PasswordAuthentication yes" /etc/ssh/sshd_config 2>/dev/null; then
        vuln_medium "SSH password authentication enabled (prefer key-based)"
    fi
    if grep -q "^PermitEmptyPasswords yes" /etc/ssh/sshd_config 2>/dev/null; then
        vuln_critical "SSH permits empty passwords!"
    fi
fi

# Check firewall
if ! iptables -L &>/dev/null && ! ufw status &>/dev/null; then
    vuln_medium "No active firewall detected"
fi

# Check ASLR
if [ "$(cat /proc/sys/kernel/randomize_va_space 2>/dev/null)" = "0" ]; then
    vuln_high "ASLR (Address Space Layout Randomization) is disabled"
fi

### ---------- VULNERABILITY SUMMARY ----------
print_section "VULNERABILITY SUMMARY"
echo "" | tee -a "$OUTFILE"
echo "╔════════════════════════════════════════════════════════════╗" | tee -a "$OUTFILE"
echo "║          VULNERABILITY ASSESSMENT RESULTS                  ║" | tee -a "$OUTFILE"
echo "╚════════════════════════════════════════════════════════════╝" | tee -a "$OUTFILE"
echo "" | tee -a "$OUTFILE"
echo -e "${RED}Critical Vulnerabilities: $CRITICAL_VULN${NC}" | tee -a "$OUTFILE"
echo -e "${RED}High Vulnerabilities: $HIGH_VULN${NC}" | tee -a "$OUTFILE"
echo -e "${YELLOW}Medium Vulnerabilities: $MEDIUM_VULN${NC}" | tee -a "$OUTFILE"
echo -e "Total Issues Found: $VULN_COUNT" | tee -a "$OUTFILE"
echo "" | tee -a "$OUTFILE"

if [ $CRITICAL_VULN -gt 0 ]; then
    echo -e "${RED}RISK LEVEL: CRITICAL${NC}" | tee -a "$OUTFILE"
elif [ $HIGH_VULN -gt 2 ]; then
    echo -e "${RED}RISK LEVEL: HIGH${NC}" | tee -a "$OUTFILE"
elif [ $MEDIUM_VULN -gt 0 ]; then
    echo -e "${YELLOW}RISK LEVEL: MODERATE${NC}" | tee -a "$OUTFILE"
else
    echo -e "${GREEN}RISK LEVEL: LOW${NC}" | tee -a "$OUTFILE"
fi

echo "" | tee -a "$OUTFILE"
echo "═══════════════════════════════════════════════════════════════" | tee -a "$OUTFILE"
echo "Scan completed: $(date)" | tee -a "$OUTFILE"
echo "Output saved to: $OUTFILE" | tee -a "$OUTFILE"
echo "═══════════════════════════════════════════════════════════════" | tee -a "$OUTFILE"
success "Intermediate scan complete!"
echo "" | tee -a "$OUTFILE"
echo "For deeper analysis with CVE lookups and exploit suggestions:" | tee -a "$OUTFILE"
echo "  → Run: ./deep_scan_online.sh" | tee -a "$OUTFILE"
echo "═══════════════════════════════════════════════════════════════" | tee -a "$OUTFILE"

exit 0
