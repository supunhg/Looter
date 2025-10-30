#!/usr/bin/env bash
# Looter - Deep Scan (Online) v1.0
# Comprehensive scan with CVE database lookups and exploit recommendations
# Requires internet connection for CVE/exploit database queries
# Usage: bash ./deep_scan_online.sh [--target HOST] [--out report.txt]

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
║               Advanced Vulnerability Assessment with CVE Lookup           ║
║                         [ DEEP SCAN - ONLINE ]                            ║
║                                                                           ║
║        Full System Analysis + CVE Database + Exploit Suggestions          ║
║               ⚠ Requires Internet Connection ⚠                            ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝

EOF
sleep 1

### ---------- DEFAULTS ----------
TARGET="127.0.0.1"
OUTFILE="deep_scan_online_$(date +%Y%m%d_%H%M%S).txt"
DEFAULT_PORTS=(21 22 23 25 53 80 110 135 139 143 443 445 587 993 995 1433 3306 3389 5432 5900 6379 8080 8443 27017)

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
LOW_VULN=0
CVE_LIST=()
EXPLOIT_LIST=()

### ---------- ARG PARSING ----------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target|-t) TARGET="$2"; shift 2 ;;
    --out|-o) OUTFILE="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 [--target HOST] [--out report.txt]"
      echo "  --target, -t    Target host/IP"
      echo "  --out, -o       Output file"
      echo ""
      echo "Requires internet connection for CVE lookups and exploit database queries"
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

vuln_low() {
    echo -e "${CYAN}[LOW]${NC} $1" | tee -a "$OUTFILE"
    LOW_VULN=$((LOW_VULN + 1))
    VULN_COUNT=$((VULN_COUNT + 1))
}

add_cve() {
    CVE_LIST+=("$1")
}

add_exploit() {
    EXPLOIT_LIST+=("$1")
}

command_exists() { command -v "$1" &> /dev/null; }

# Check internet connectivity
check_internet() {
    if ping -c 1 8.8.8.8 &>/dev/null || ping -c 1 1.1.1.1 &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Query CVE database (using NIST NVD or similar)
query_cve() {
    local software="$1"
    local version="$2"
    
    info "Querying CVE database for $software $version..."
    
    # Use cve-search.org or NIST NVD API
    local cve_url="https://cve.circl.lu/api/search/${software}/${version}"
    
    if command_exists curl; then
        local result=$(curl -s --connect-timeout 10 "$cve_url" 2>/dev/null)
        if [ ! -z "$result" ] && [ "$result" != "[]" ]; then
            echo "$result" | grep -oP 'CVE-\d{4}-\d+' | head -10 | while read cve; do
                add_cve "$cve"
                echo "  → $cve" | tee -a "$OUTFILE"
            done
        fi
    fi
}

# Search for exploits in ExploitDB
search_exploits() {
    local software="$1"
    local version="$2"
    
    info "Searching for exploits: $software $version..."
    
    # Use searchsploit if available
    if command_exists searchsploit; then
        searchsploit "$software $version" 2>/dev/null | grep -v "Exploits: No Results" | head -10 | tee -a "$OUTFILE"
    else
        # Fallback: query exploit-db.com
        if command_exists curl; then
            local search_query=$(echo "$software $version" | sed 's/ /+/g')
            warn "searchsploit not installed. Use: apt install exploitdb"
            info "Manual search: https://www.exploit-db.com/search?q=$search_query"
        fi
    fi
}

# Get Metasploit modules
get_msf_modules() {
    local software="$1"
    
    if [ -d "/usr/share/metasploit-framework/modules" ]; then
        info "Searching Metasploit modules for $software..."
        find /usr/share/metasploit-framework/modules -type f -name "*.rb" | xargs grep -l "$software" 2>/dev/null | head -5 | while read module; do
            echo "  → $(basename $module .rb)" | tee -a "$OUTFILE"
            add_exploit "MSF: $(basename $module .rb)"
        done
    fi
}

### ---------- START SCAN ----------
echo "═══════════════════════════════════════════════════════════════" | tee "$OUTFILE"
echo "LOOTER - DEEP SCAN (ONLINE)" | tee -a "$OUTFILE"
echo "═══════════════════════════════════════════════════════════════" | tee -a "$OUTFILE"
echo "Scan started: $(date)" | tee -a "$OUTFILE"
echo "Target: $TARGET" | tee -a "$OUTFILE"
echo "User: $(whoami)" | tee -a "$OUTFILE"
echo "═══════════════════════════════════════════════════════════════" | tee -a "$OUTFILE"

# Check internet connectivity
print_section "CONNECTIVITY CHECK"
if check_internet; then
    success "Internet connection available - CVE/Exploit lookups enabled"
else
    error "No internet connection detected!"
    warn "CVE and exploit database queries will be limited"
    warn "Consider running deep_scan_offline.sh instead"
    sleep 3
fi

# Include all intermediate scan checks
info "Running comprehensive system enumeration..."

### ---------- SYSTEM INFORMATION ----------
print_section "SYSTEM INFORMATION"
echo "Hostname: $(hostname)" | tee -a "$OUTFILE"
echo "FQDN: $(hostname -f 2>/dev/null || echo 'N/A')" | tee -a "$OUTFILE"
echo "Kernel: $(uname -r)" | tee -a "$OUTFILE"
echo "OS: $(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'=' -f2 | tr -d '"')" | tee -a "$OUTFILE"
echo "Architecture: $(uname -m)" | tee -a "$OUTFILE"
echo "Uptime: $(uptime | cut -d',' -f1 | cut -d' ' -f2-)" | tee -a "$OUTFILE"

### ---------- HARDWARE ----------
print_section "HARDWARE INFORMATION"
echo "CPU: $(lscpu | grep 'Model name' | cut -d':' -f2 | xargs)" | tee -a "$OUTFILE"
echo "Cores: $(nproc)" | tee -a "$OUTFILE"
echo "Memory: $(free -h | grep Mem | awk '{print $2}')" | tee -a "$OUTFILE"
echo "Disk: $(df -h / | tail -1 | awk '{print $2 " (" $5 " used)"}')" | tee -a "$OUTFILE"

### ---------- COMPREHENSIVE VULNERABILITY SCANNING ----------
print_section "VULNERABILITY SCANNING WITH CVE LOOKUP"

# Kernel vulnerability check
KERNEL_VERSION=$(uname -r)
info "Analyzing kernel: $KERNEL_VERSION"
KERNEL_MAJOR=$(echo $KERNEL_VERSION | cut -d'.' -f1)
KERNEL_MINOR=$(echo $KERNEL_VERSION | cut -d'.' -f2)

if [ "$KERNEL_MAJOR" -lt 5 ] || ([ "$KERNEL_MAJOR" -eq 5 ] && [ "$KERNEL_MINOR" -lt 10 ]); then
    vuln_high "Kernel version is outdated: $KERNEL_VERSION"
    add_cve "Multiple kernel CVEs possible"
    
    # Check for Dirty COW
    if [ "$KERNEL_MAJOR" -lt 4 ] || ([ "$KERNEL_MAJOR" -eq 4 ] && [ "$KERNEL_MINOR" -lt 9 ]); then
        vuln_critical "Kernel vulnerable to Dirty COW (CVE-2016-5195)"
        add_cve "CVE-2016-5195"
        add_exploit "DirtyCOW Local Privilege Escalation"
    fi
    
    # Query for kernel exploits
    if check_internet; then
        search_exploits "linux kernel" "$KERNEL_MAJOR.$KERNEL_MINOR"
    fi
fi

# OpenSSH vulnerability check
if command_exists sshd; then
    SSH_VERSION=$(sshd -V 2>&1 | grep -oP 'OpenSSH_\K[\d.]+' | cut -d'_' -f1)
    info "Analyzing OpenSSH: $SSH_VERSION"
    
    # Check for specific CVEs
    SSH_MAJOR=$(echo $SSH_VERSION | cut -d'.' -f1)
    SSH_MINOR=$(echo $SSH_VERSION | cut -d'.' -f2)
    
    if [ "$SSH_MAJOR" -lt 8 ]; then
        vuln_critical "OpenSSH version is severely outdated: $SSH_VERSION"
        add_cve "CVE-2018-15473 - Username Enumeration"
        add_exploit "OpenSSH Username Enumeration"
        
        if check_internet; then
            query_cve "openssh" "$SSH_VERSION"
            search_exploits "openssh" "$SSH_VERSION"
        fi
    elif [ "$SSH_MAJOR" -eq 8 ] && [ "$SSH_MINOR" -lt 4 ]; then
        vuln_high "OpenSSH has known vulnerabilities: $SSH_VERSION"
        if check_internet; then
            query_cve "openssh" "$SSH_VERSION"
        fi
    fi
fi

# Apache vulnerability check
if command_exists apache2; then
    APACHE_VERSION=$(apache2 -v 2>/dev/null | grep -oP 'Apache/\K[\d.]+')
    info "Analyzing Apache: $APACHE_VERSION"
    
    APACHE_MAJOR=$(echo $APACHE_VERSION | cut -d'.' -f1)
    APACHE_MINOR=$(echo $APACHE_VERSION | cut -d'.' -f2)
    APACHE_PATCH=$(echo $APACHE_VERSION | cut -d'.' -f3)
    
    if [ "$APACHE_MINOR" -eq 4 ] && [ "$APACHE_PATCH" -lt 51 ]; then
        vuln_critical "Apache vulnerable to path traversal and RCE"
        add_cve "CVE-2021-41773"
        add_cve "CVE-2021-42013"
        add_exploit "Apache 2.4.49/2.4.50 Path Traversal"
        info "  → Path traversal allows reading arbitrary files"
        info "  → RCE possible in certain configurations"
        
        if check_internet; then
            search_exploits "apache" "$APACHE_VERSION"
            get_msf_modules "apache_normalize_path"
        fi
    fi
    
    if check_internet; then
        query_cve "apache" "$APACHE_VERSION"
    fi
fi

# Nginx vulnerability check
if command_exists nginx; then
    NGINX_VERSION=$(nginx -v 2>&1 | grep -oP 'nginx/\K[\d.]+')
    info "Analyzing Nginx: $NGINX_VERSION"
    
    if check_internet; then
        query_cve "nginx" "$NGINX_VERSION"
        search_exploits "nginx" "$NGINX_VERSION"
    fi
fi

# MySQL vulnerability check
if command_exists mysql; then
    MYSQL_VERSION=$(mysql --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' | head -1)
    info "Analyzing MySQL: $MYSQL_VERSION"
    
    MYSQL_MAJOR=$(echo $MYSQL_VERSION | cut -d'.' -f1)
    
    if [ "$MYSQL_MAJOR" -lt 8 ]; then
        vuln_high "MySQL version is outdated: $MYSQL_VERSION"
        if check_internet; then
            query_cve "mysql" "$MYSQL_VERSION"
            search_exploits "mysql" "$MYSQL_VERSION"
        fi
    fi
fi

# PHP vulnerability check
if command_exists php; then
    PHP_VERSION=$(php --version | grep -oP 'PHP \K[\d.]+' | head -1)
    info "Analyzing PHP: $PHP_VERSION"
    
    PHP_MAJOR=$(echo $PHP_VERSION | cut -d'.' -f1)
    PHP_MINOR=$(echo $PHP_VERSION | cut -d'.' -f2)
    
    if [ "$PHP_MAJOR" -lt 7 ] || ([ "$PHP_MAJOR" -eq 7 ] && [ "$PHP_MINOR" -lt 4 ]); then
        vuln_critical "PHP version is end-of-life: $PHP_VERSION"
        add_cve "Multiple unpatched vulnerabilities"
        info "  → No security updates available for this version"
        
        if check_internet; then
            query_cve "php" "$PHP_VERSION"
            search_exploits "php" "$PHP_VERSION"
        fi
    fi
fi

# Docker vulnerability check
if command_exists docker; then
    DOCKER_VERSION=$(docker --version | grep -oP '\d+\.\d+\.\d+')
    info "Analyzing Docker: $DOCKER_VERSION"
    
    # Check if running in container
    if [ -f "/.dockerenv" ]; then
        vuln_high "System is running inside a Docker container"
        info "  → Check for container escape vulnerabilities"
        
        # Check for privileged mode
        if grep -q "CapEff.*0000003fffffffff" /proc/self/status 2>/dev/null; then
            vuln_critical "Container is running in PRIVILEGED mode!"
            add_exploit "Docker Privileged Container Escape"
        fi
        
        # Check for mounted docker socket
        if [ -S "/var/run/docker.sock" ]; then
            vuln_critical "Docker socket mounted inside container!"
            add_exploit "Docker Socket Container Escape"
        fi
    fi
    
    if check_internet; then
        query_cve "docker" "$DOCKER_VERSION"
    fi
fi

### ---------- COMPREHENSIVE PORT SCAN ----------
print_section "COMPREHENSIVE PORT SCAN & SERVICE ENUMERATION"

if command_exists nmap; then
    success "Running aggressive nmap scan with version detection..."
    nmap -A -sV -sC -Pn --script vuln -T4 -p- "$TARGET" 2>/dev/null | tee -a "$OUTFILE"
    
    info "Running nmap NSE vulnerability scripts..."
    nmap --script "vuln,exploit" -Pn -p $(echo ${DEFAULT_PORTS[@]} | tr ' ' ',') "$TARGET" 2>/dev/null | tee -a "$OUTFILE"
else
    warn "nmap not installed - install for comprehensive scanning"
fi

### ---------- WEB APPLICATION SCANNING ----------
if command_exists curl && check_internet; then
    print_section "WEB APPLICATION VULNERABILITY SCAN"
    
    # Check if web server is running
    for port in 80 443 8080 8443; do
        if timeout 2 bash -c "echo >/dev/tcp/$TARGET/$port" 2>/dev/null; then
            info "Web server detected on port $port"
            
            # Get headers
            info "Analyzing HTTP headers..."
            curl -I -s --connect-timeout 5 "http://$TARGET:$port" 2>/dev/null | head -20 | tee -a "$OUTFILE"
            
            # Check for common vulnerabilities
            info "Checking for common web vulnerabilities..."
            
            # Check for server version disclosure
            SERVER_HEADER=$(curl -I -s "http://$TARGET:$port" 2>/dev/null | grep -i "Server:")
            if [ ! -z "$SERVER_HEADER" ]; then
                warn "Server version disclosed: $SERVER_HEADER"
                vuln_low "Server version disclosure in HTTP headers"
            fi
            
            # Check for security headers
            HEADERS=$(curl -I -s "http://$TARGET:$port" 2>/dev/null)
            echo "$HEADERS" | grep -qi "X-Frame-Options" || vuln_medium "Missing X-Frame-Options header (clickjacking risk)"
            echo "$HEADERS" | grep -qi "X-Content-Type-Options" || vuln_low "Missing X-Content-Type-Options header"
            echo "$HEADERS" | grep -qi "Strict-Transport-Security" || vuln_medium "Missing HSTS header (HTTPS)"
            echo "$HEADERS" | grep -qi "Content-Security-Policy" || vuln_low "Missing Content-Security-Policy header"
        fi
    done
fi

### ---------- EXPLOIT RECOMMENDATIONS ----------
print_section "EXPLOIT RECOMMENDATIONS"

if [ ${#EXPLOIT_LIST[@]} -gt 0 ]; then
    info "Potential exploits found:"
    printf '%s\n' "${EXPLOIT_LIST[@]}" | tee -a "$OUTFILE"
else
    info "No specific exploits identified in database"
fi

info "Additional exploit resources:"
echo "  → ExploitDB: https://www.exploit-db.com/" | tee -a "$OUTFILE"
echo "  → Packet Storm: https://packetstormsecurity.com/" | tee -a "$OUTFILE"
echo "  → GitHub: https://github.com/search?q=exploit" | tee -a "$OUTFILE"
echo "  → Metasploit: msfconsole -q -x 'search $TARGET'" | tee -a "$OUTFILE"

### ---------- PRIVILEGE ESCALATION VECTORS ----------
print_section "PRIVILEGE ESCALATION ANALYSIS"

info "Checking for privilege escalation vectors..."

# SUID binaries
SUID_COUNT=$(find / -perm -4000 -type f 2>/dev/null | wc -l)
info "SUID binaries found: $SUID_COUNT"
find / -perm -4000 -type f 2>/dev/null | head -20 | tee -a "$OUTFILE"

# Check for dangerous SUID
DANGEROUS_SUID=$(find / -perm -4000 -type f 2>/dev/null | grep -E "nmap|vim|find|bash|more|less|nano|cp")
if [ ! -z "$DANGEROUS_SUID" ]; then
    vuln_critical "Dangerous SUID binaries found!"
    echo "$DANGEROUS_SUID" | tee -a "$OUTFILE"
    add_exploit "SUID Binary Privilege Escalation"
fi

# Sudo misconfigurations
SUDO_L=$(sudo -l 2>/dev/null)
if echo "$SUDO_L" | grep -qE "NOPASSWD.*ALL"; then
    vuln_critical "User can run all commands with NOPASSWD sudo"
    add_exploit "Sudo NOPASSWD Privilege Escalation"
fi

### ---------- CREDENTIAL HUNTING ----------
print_section "CREDENTIAL & SECRET HUNTING"

echo -e "\n${CYAN}Searching for credentials and secrets...${NC}" | tee -a "$OUTFILE"

# Search for SSH keys
echo -e "\n${YELLOW}SSH Keys:${NC}" | tee -a "$OUTFILE"
find / -type f \( -name "id_rsa*" -o -name "id_dsa*" -o -name "id_ecdsa*" -o -name "id_ed25519*" \) 2>/dev/null | head -20 | tee -a "$OUTFILE"

# Check for readable SSH keys
for keyfile in $(find /home /root -name "id_rsa" -o -name "id_dsa" 2>/dev/null | head -10); do
    if [ -r "$keyfile" ]; then
        vuln_high "Readable SSH private key: $keyfile"
    fi
done

# Search for password files
echo -e "\n${YELLOW}Password & Credential Files:${NC}" | tee -a "$OUTFILE"
find / -type f \( -name "*.pem" -o -name "*.key" -o -name "*.p12" -o -name "*.pfx" -o -name "credentials" -o -name ".env*" \) 2>/dev/null | grep -v "/proc\|/sys" | head -20 | tee -a "$OUTFILE"

# AWS credentials
if [ -f "$HOME/.aws/credentials" ]; then
    vuln_high "AWS credentials file found: $HOME/.aws/credentials"
fi

# Database config files
echo -e "\n${YELLOW}Database Configuration Files:${NC}" | tee -a "$OUTFILE"
find /var/www /home /opt -type f \( -name "database.yml" -o -name "db.conf" -o -name "config.php" \) 2>/dev/null | head -10 | tee -a "$OUTFILE"

# Search for passwords in files
echo -e "\n${YELLOW}Files with password references:${NC}" | tee -a "$OUTFILE"
find /var/www /home -type f -name "*.conf" -o -name "*.config" -o -name "*.ini" 2>/dev/null | xargs grep -l -i "password\|passwd" 2>/dev/null | head -15 | tee -a "$OUTFILE"

### ---------- BASH HISTORY ANALYSIS ----------
print_section "BASH HISTORY ANALYSIS"

echo -e "\n${CYAN}Analyzing bash history for sensitive commands...${NC}" | tee -a "$OUTFILE"

for user_home in /home/* /root; do
    if [ -f "$user_home/.bash_history" ] && [ -r "$user_home/.bash_history" ]; then
        USER=$(basename "$user_home")
        echo -e "\n${YELLOW}History for $USER:${NC}" | tee -a "$OUTFILE"
        
        # Check for passwords in history
        PASS_IN_HIST=$(grep -i -E "password|passwd|mysql.*-p|psql.*password|sudo.*-S" "$user_home/.bash_history" 2>/dev/null | head -5)
        if [ ! -z "$PASS_IN_HIST" ]; then
            vuln_high "Passwords/credentials found in $USER's bash history!"
            echo "$PASS_IN_HIST" | sed 's/^/  /' | tee -a "$OUTFILE"
        fi
        
        # Check for SSH commands
        SSH_CMDS=$(grep -E "ssh.*@|scp.*@" "$user_home/.bash_history" 2>/dev/null | tail -5)
        if [ ! -z "$SSH_CMDS" ]; then
            echo "  SSH commands found:" | tee -a "$OUTFILE"
            echo "$SSH_CMDS" | sed 's/^/    /' | tee -a "$OUTFILE"
        fi
        
        # Check for wget/curl downloads
        DOWNLOADS=$(grep -E "wget|curl.*http" "$user_home/.bash_history" 2>/dev/null | tail -5)
        if [ ! -z "$DOWNLOADS" ]; then
            echo "  Download commands:" | tee -a "$OUTFILE"
            echo "$DOWNLOADS" | sed 's/^/    /' | tee -a "$OUTFILE"
        fi
    fi
done

### ---------- LD_PRELOAD & LIBRARY HIJACKING ----------
print_section "LD_PRELOAD & LIBRARY HIJACKING"

echo -e "\n${CYAN}Checking for LD_PRELOAD and library hijacking vectors...${NC}" | tee -a "$OUTFILE"

# Check for LD_PRELOAD in environment
if [ ! -z "$LD_PRELOAD" ]; then
    vuln_high "LD_PRELOAD is set: $LD_PRELOAD"
fi

# Check for LD_LIBRARY_PATH
if [ ! -z "$LD_LIBRARY_PATH" ]; then
    info "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
fi

# Check /etc/ld.so.preload
if [ -f "/etc/ld.so.preload" ]; then
    info "/etc/ld.so.preload exists:"
    cat /etc/ld.so.preload 2>/dev/null | tee -a "$OUTFILE"
    
    if [ -w "/etc/ld.so.preload" ]; then
        vuln_critical "/etc/ld.so.preload is WRITABLE!"
        add_exploit "LD_PRELOAD Library Injection"
    fi
fi

# Check library search paths
echo -e "\n${CYAN}Library search paths:${NC}" | tee -a "$OUTFILE"
cat /etc/ld.so.conf 2>/dev/null | tee -a "$OUTFILE"
cat /etc/ld.so.conf.d/* 2>/dev/null | head -20 | tee -a "$OUTFILE"

# Check if any library paths are writable
for lib_dir in /lib /lib64 /usr/lib /usr/lib64 /usr/local/lib; do
    if [ -w "$lib_dir" 2>/dev/null ]; then
        vuln_critical "Library directory $lib_dir is WRITABLE!"
        add_exploit "Shared Library Hijacking"
    fi
done

### ---------- POLICYKIT & DBUS ANALYSIS ----------
print_section "POLICYKIT (POLKIT) & D-BUS ANALYSIS"

echo -e "\n${CYAN}Checking PolicyKit vulnerabilities...${NC}" | tee -a "$OUTFILE"

# Check pkexec version
if command_exists pkexec; then
    PKEXEC_VERSION=$(pkexec --version 2>&1 | grep -oP '\d+\.\d+')
    info "pkexec version: $PKEXEC_VERSION"
    
    # Check for CVE-2021-4034 (PwnKit)
    if command_exists pkexec && [ -u "$(which pkexec 2>/dev/null)" ]; then
        vuln_high "pkexec is SUID - check for CVE-2021-4034 (PwnKit)"
        add_cve "CVE-2021-4034"
        add_exploit "PwnKit Local Privilege Escalation"
        
        if check_internet; then
            search_exploits "pkexec CVE-2021-4034" ""
        fi
    fi
fi

# Check polkit rules
if [ -d "/etc/polkit-1/rules.d" ]; then
    echo -e "\n${YELLOW}PolicyKit rules:${NC}" | tee -a "$OUTFILE"
    ls -la /etc/polkit-1/rules.d/ 2>/dev/null | tee -a "$OUTFILE"
    
    # Check for writable polkit rules
    WRITABLE_POLKIT=$(find /etc/polkit-1/rules.d -type f -writable 2>/dev/null)
    if [ ! -z "$WRITABLE_POLKIT" ]; then
        vuln_critical "Writable PolicyKit rules found!"
        echo "$WRITABLE_POLKIT" | tee -a "$OUTFILE"
    fi
fi

# D-Bus Analysis
echo -e "\n${CYAN}Checking D-Bus configuration...${NC}" | tee -a "$OUTFILE"

if command_exists dbus-send; then
    info "Listing D-Bus services..."
    dbus-send --system --dest=org.freedesktop.DBus --type=method_call --print-reply /org/freedesktop/DBus org.freedesktop.DBus.ListNames 2>/dev/null | head -30 | tee -a "$OUTFILE"
fi

# Check for writable D-Bus config
if [ -w "/etc/dbus-1/system.d" ]; then
    vuln_high "/etc/dbus-1/system.d is writable!"
fi

if [ -d "/etc/dbus-1/system.d" ]; then
    DBUS_CONFIGS=$(find /etc/dbus-1/system.d -type f -writable 2>/dev/null)
    if [ ! -z "$DBUS_CONFIGS" ]; then
        vuln_high "Writable D-Bus configuration files found!"
        echo "$DBUS_CONFIGS" | tee -a "$OUTFILE"
    fi
fi

### ---------- CVE SUMMARY ----------
print_section "CVE SUMMARY"

if [ ${#CVE_LIST[@]} -gt 0 ]; then
    info "CVEs identified:"
    printf '%s\n' "${CVE_LIST[@]}" | sort -u | tee -a "$OUTFILE"
    
    echo "" | tee -a "$OUTFILE"
    info "CVE Details:"
    for cve in $(printf '%s\n' "${CVE_LIST[@]}" | sort -u); do
        echo "  → https://nvd.nist.gov/vuln/detail/$cve" | tee -a "$OUTFILE"
    done
else
    success "No specific CVEs identified (or offline scan)"
fi

### ---------- FINAL REPORT ----------
print_section "COMPREHENSIVE VULNERABILITY REPORT"

echo "" | tee -a "$OUTFILE"
echo "╔════════════════════════════════════════════════════════════╗" | tee -a "$OUTFILE"
echo "║            VULNERABILITY ASSESSMENT RESULTS                ║" | tee -a "$OUTFILE"
echo "╚════════════════════════════════════════════════════════════╝" | tee -a "$OUTFILE"
echo "" | tee -a "$OUTFILE"
echo -e "${RED}Critical: $CRITICAL_VULN${NC}" | tee -a "$OUTFILE"
echo -e "${RED}High: $HIGH_VULN${NC}" | tee -a "$OUTFILE"
echo -e "${YELLOW}Medium: $MEDIUM_VULN${NC}" | tee -a "$OUTFILE"
echo -e "${CYAN}Low: $LOW_VULN${NC}" | tee -a "$OUTFILE"
echo "Total: $VULN_COUNT" | tee -a "$OUTFILE"
echo "" | tee -a "$OUTFILE"
echo "CVEs Found: ${#CVE_LIST[@]}" | tee -a "$OUTFILE"
echo "Exploits Available: ${#EXPLOIT_LIST[@]}" | tee -a "$OUTFILE"
echo "" | tee -a "$OUTFILE"

# Risk score
RISK_SCORE=$((CRITICAL_VULN * 10 + HIGH_VULN * 7 + MEDIUM_VULN * 4 + LOW_VULN * 1))
echo "Risk Score: $RISK_SCORE" | tee -a "$OUTFILE"

if [ $CRITICAL_VULN -gt 0 ]; then
    echo -e "${RED}╔════════════════════════════════════════════════════════════╗${NC}" | tee -a "$OUTFILE"
    echo -e "${RED}║  RISK LEVEL: CRITICAL - IMMEDIATE ACTION REQUIRED         ║${NC}" | tee -a "$OUTFILE"
    echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}" | tee -a "$OUTFILE"
elif [ $HIGH_VULN -gt 3 ]; then
    echo -e "${RED}RISK LEVEL: HIGH${NC}" | tee -a "$OUTFILE"
elif [ $HIGH_VULN -gt 0 ] || [ $MEDIUM_VULN -gt 5 ]; then
    echo -e "${YELLOW}RISK LEVEL: ELEVATED${NC}" | tee -a "$OUTFILE"
else
    echo -e "${GREEN}RISK LEVEL: MODERATE${NC}" | tee -a "$OUTFILE"
fi

echo "" | tee -a "$OUTFILE"
echo "═══════════════════════════════════════════════════════════════" | tee -a "$OUTFILE"
echo "Scan completed: $(date)" | tee -a "$OUTFILE"
echo "Output saved to: $OUTFILE" | tee -a "$OUTFILE"
echo "═══════════════════════════════════════════════════════════════" | tee -a "$OUTFILE"
success "Deep scan (online) complete!"
echo "" | tee -a "$OUTFILE"

exit 0
