#!/bin/bash

# ============================================================================
# CONFIGURATION SECTION - Enable/Disable Scan Modules
# ============================================================================
SCAN_BASIC_SYSTEM=true              # System info, hardware, kernel
SCAN_HARDWARE_DETAILED=true         # Detailed hardware enumeration
SCAN_NETWORK=true                   # Network configuration and connections
SCAN_NETWORK_DISCOVERY=true         # Local network host discovery (may be slow)
SCAN_SERVICES=true                  # Running services and processes
SCAN_USERS_AUTH=true                # Users, groups, authentication
SCAN_SSH_ANALYSIS=true              # SSH configuration and vulnerabilities
SCAN_FIREWALL=true                  # Firewall rules and status
SCAN_SOFTWARE=true                  # Installed packages and applications
SCAN_STORAGE=true                   # Disk, filesystem, mount points
SCAN_SECURITY_AUDIT=true            # SUID/SGID, world-writable files, etc.
SCAN_PRIVILEGE_ESCALATION=true      # Privilege escalation vectors
SCAN_CONTAINERS=true                # Docker, Podman, container detection
SCAN_DATABASES=true                 # Database detection and info
SCAN_WEB_SERVERS=true               # Web server detection
SCAN_SYSTEM_HARDENING=true          # SELinux, AppArmor, security features
SCAN_LOGS=true                      # System logs and recent events
SCAN_CRON_SCHEDULED=true            # Cron jobs and scheduled tasks
SCAN_VULNERABILITY_SCORING=true     # Automated vulnerability assessment
SCAN_PERFORMANCE=true               # Performance metrics and statistics

# Network Discovery Settings
NETWORK_SCAN_TIMEOUT=1              # Ping timeout in seconds
NETWORK_SCAN_THREADS=50             # Max concurrent ping threads

# Privilege Escalation Checks
CHECK_SUID_SGID=true                # Find SUID/SGID binaries
CHECK_WORLD_WRITABLE=true           # Find world-writable files
CHECK_NO_OWNER=true                 # Find files with no owner
CHECK_WEAK_PERMISSIONS=true         # Check for weak file permissions
CHECK_SUDO_MISCONFIG=true           # Check sudo misconfigurations
CHECK_KERNEL_EXPLOITS=true          # Check for known kernel vulnerabilities

# Output Settings
OUTPUT_VERBOSE=true                 # Detailed output
OUTPUT_COLOR=true                   # Colored terminal output

# ============================================================================
# Colors for output
# ============================================================================
if [ "$OUTPUT_COLOR" = true ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    MAGENTA='\033[0;35m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    CYAN=''
    MAGENTA=''
    NC=''
fi

# Output file with timestamp
OUTPUT_FILE="system_scan_$(date +%Y-%m-%d_%H-%M-%S).txt"
VULN_SCORE=0
VULN_CRITICAL=0
VULN_HIGH=0
VULN_MEDIUM=0
VULN_LOW=0

# Function to print section headers
print_section() {
    echo -e "\n${BLUE}=== $1 ===${NC}" | tee -a "$OUTPUT_FILE"
    echo "=== $1 ===" >> "$OUTPUT_FILE"
}

# Function to run command and log output
run_cmd() {
    echo -e "\n${YELLOW}Command: $1${NC}" | tee -a "$OUTPUT_FILE"
    echo "Command: $1" >> "$OUTPUT_FILE"
    eval "$1" 2>&1 | tee -a "$OUTPUT_FILE"
}

# Function to add vulnerability finding
add_vuln() {
    local severity=$1
    local description=$2
    local details=$3
    
    case $severity in
        CRITICAL)
            VULN_CRITICAL=$((VULN_CRITICAL + 1))
            VULN_SCORE=$((VULN_SCORE + 10))
            ;;
        HIGH)
            VULN_HIGH=$((VULN_HIGH + 1))
            VULN_SCORE=$((VULN_SCORE + 7))
            ;;
        MEDIUM)
            VULN_MEDIUM=$((VULN_MEDIUM + 1))
            VULN_SCORE=$((VULN_SCORE + 4))
            ;;
        LOW)
            VULN_LOW=$((VULN_LOW + 1))
            VULN_SCORE=$((VULN_SCORE + 1))
            ;;
    esac
    
    echo -e "${RED}[${severity}]${NC} ${description}" | tee -a "$OUTPUT_FILE"
    if [ ! -z "$details" ]; then
        echo "  Details: $details" | tee -a "$OUTPUT_FILE"
    fi
}

# Function to check if running as root
is_root() {
    [ "$EUID" -eq 0 ]
}

# Start the scan
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     COMPREHENSIVE SECURITY AUDIT & SYSTEM SCANNER         ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo "Scan started at: $(date)" | tee "$OUTPUT_FILE"
echo "Hostname: $(hostname)" | tee -a "$OUTPUT_FILE"
echo "User: $(whoami)" | tee -a "$OUTPUT_FILE"
if is_root; then
    echo -e "${GREEN}Privilege Level: ROOT${NC}" | tee -a "$OUTPUT_FILE"
else
    echo -e "${YELLOW}Privilege Level: USER (some checks require root)${NC}" | tee -a "$OUTPUT_FILE"
fi
echo "==============================================" | tee -a "$OUTPUT_FILE"

# System Information
if [ "$SCAN_BASIC_SYSTEM" = true ]; then
    print_section "SYSTEM INFORMATION"
    run_cmd "uname -a"
    run_cmd "cat /etc/*-release"
    run_cmd "hostnamectl"
    run_cmd "uptime"
    run_cmd "who -b"
    run_cmd "timedatectl 2>/dev/null || date"
fi

# Hardware Information
if [ "$SCAN_HARDWARE_DETAILED" = true ]; then
    print_section "HARDWARE INFORMATION"
    run_cmd "lscpu"
    run_cmd "cat /proc/cpuinfo | grep -E 'processor|model name|cpu cores|MHz' | head -20"
    run_cmd "free -h"
    run_cmd "lsblk"
    run_cmd "df -hT"
    run_cmd "lshw -short 2>/dev/null || echo 'lshw not available'"
    
    # BIOS/UEFI and Firmware
    print_section "BIOS/FIRMWARE INFORMATION"
    run_cmd "dmidecode -t bios 2>/dev/null || echo 'dmidecode not available/requires root'"
    run_cmd "cat /sys/class/dmi/id/* 2>/dev/null | head -20"
    
    # System Manufacturer
    print_section "SYSTEM VENDOR INFORMATION"
    run_cmd "cat /sys/class/dmi/id/sys_vendor 2>/dev/null || echo 'Vendor info not available'"
    run_cmd "cat /sys/class/dmi/id/product_name 2>/dev/null || echo 'Product name not available'"
    run_cmd "cat /sys/class/dmi/id/board_vendor 2>/dev/null || echo 'Board vendor not available'"
fi

# Kernel and Modules
if [ "$SCAN_BASIC_SYSTEM" = true ]; then
    print_section "KERNEL INFORMATION"
    run_cmd "uname -r"
    run_cmd "cat /proc/version"
    run_cmd "lsmod | head -30"
    run_cmd "sysctl -a 2>/dev/null | grep -E 'kernel.randomize|kernel.kptr_restrict|kernel.dmesg_restrict' || echo 'Cannot read sysctl'"
fi

# Memory Details
if [ "$SCAN_HARDWARE_DETAILED" = true ]; then
    print_section "MEMORY INFORMATION"
    run_cmd "cat /proc/meminfo | head -20"
    run_cmd "dmidecode -t memory 2>/dev/null | head -50 || echo 'Detailed memory info requires root'"
    run_cmd "vmstat 1 3"
fi

# USB Devices
if [ "$SCAN_HARDWARE_DETAILED" = true ]; then
    print_section "USB DEVICES"
    run_cmd "lsusb 2>/dev/null || echo 'lsusb not available'"
    run_cmd "lsusb -t 2>/dev/null || echo 'lsusb tree view not available'"
fi

# PCI Devices
if [ "$SCAN_HARDWARE_DETAILED" = true ]; then
    print_section "PCI DEVICES"
    run_cmd "lspci 2>/dev/null || echo 'lspci not available'"
    run_cmd "lspci -v 2>/dev/null | head -50 || echo 'Detailed PCI info not available'"
fi

# Storage Analysis
if [ "$SCAN_STORAGE" = true ]; then
    print_section "STORAGE & FILESYSTEM ANALYSIS"
    run_cmd "df -hT"
    run_cmd "df -i"
    run_cmd "mount | column -t"
    run_cmd "cat /proc/mounts"
    run_cmd "lsblk -f"
    run_cmd "fdisk -l 2>/dev/null || echo 'fdisk requires root'"
    run_cmd "blkid 2>/dev/null || echo 'blkid requires root'"
    
    # Disk I/O statistics
    run_cmd "iostat 2>/dev/null || echo 'iostat not available (install sysstat)'"
    
    # SMART data
    echo -e "\n${CYAN}Checking SMART disk health...${NC}" | tee -a "$OUTPUT_FILE"
    if command -v smartctl &> /dev/null; then
        for disk in $(lsblk -d -n -o NAME | grep -E '^sd|^nvme'); do
            run_cmd "smartctl -H /dev/$disk 2>/dev/null || echo 'Cannot read SMART data for $disk'"
        done
    else
        echo "smartctl not available (install smartmontools)" | tee -a "$OUTPUT_FILE"
    fi
    
    # Find largest directories
    echo -e "\n${CYAN}Finding largest directories (top 10)...${NC}" | tee -a "$OUTPUT_FILE"
    run_cmd "du -h / 2>/dev/null | sort -rh | head -20 || du -h /home 2>/dev/null | sort -rh | head -10"
fi

# Installed Software
if [ "$SCAN_SOFTWARE" = true ]; then
    print_section "INSTALLED SOFTWARE"
    
    # Package Managers - check which are available
    print_section "PACKAGE MANAGER INFORMATION"
    
    # Debian/Ubuntu
    if command -v dpkg &> /dev/null; then
        run_cmd "dpkg -l | wc -l"
        run_cmd "dpkg -l | tail -30"
    fi
    
    # RedHat/CentOS
    if command -v rpm &> /dev/null; then
        run_cmd "rpm -qa | wc -l"
        run_cmd "rpm -qa | tail -30"
    fi
    
    # Arch
    if command -v pacman &> /dev/null; then
        run_cmd "pacman -Q | wc -l"
        run_cmd "pacman -Q | tail -30"
    fi
    
    # Snap packages
    if command -v snap &> /dev/null; then
        run_cmd "snap list 2>/dev/null || echo 'Snap not available'"
    fi
    
    # Flatpak packages
    if command -v flatpak &> /dev/null; then
        run_cmd "flatpak list 2>/dev/null || echo 'Flatpak not available'"
    fi
    
    # Check for security updates
    echo -e "\n${CYAN}Checking for security updates...${NC}" | tee -a "$OUTPUT_FILE"
    if command -v apt &> /dev/null; then
        run_cmd "apt list --upgradable 2>/dev/null | grep -i security | head -20"
    elif command -v yum &> /dev/null; then
        run_cmd "yum list updates --security 2>/dev/null | head -20"
    fi
fi

# Services and Processes
if [ "$SCAN_SERVICES" = true ]; then
    print_section "SERVICES AND PROCESSES"
    run_cmd "ps aux --sort=-%cpu | head -30"
    run_cmd "ps aux --sort=-%mem | head -20"
    run_cmd "systemctl list-units --type=service --state=running 2>/dev/null | head -30"
    run_cmd "systemctl list-unit-files --type=service --state=enabled 2>/dev/null | head -30"
    
    # Process tree
    run_cmd "pstree -p 2>/dev/null | head -50 || ps auxf | head -50"
    
    # Check for zombie processes
    echo -e "\n${CYAN}Checking for zombie processes...${NC}" | tee -a "$OUTPUT_FILE"
    run_cmd "ps aux | awk '\$8 ~ /Z/ { print }'"
fi

# Performance Metrics
if [ "$SCAN_PERFORMANCE" = true ]; then
    print_section "PERFORMANCE METRICS"
    run_cmd "uptime"
    run_cmd "top -b -n 1 | head -20"
    run_cmd "free -h"
    run_cmd "vmstat 1 5"
    run_cmd "mpstat 2>/dev/null || echo 'mpstat not available'"
    run_cmd "sar -u 2>/dev/null || echo 'sar not available'"
fi

# Network Information
if [ "$SCAN_NETWORK" = true ]; then
    print_section "NETWORK INFORMATION"
    run_cmd "ip addr show"
    run_cmd "ip link show"
    run_cmd "ip route show"
    run_cmd "ip -6 route show"
    run_cmd "ss -tuln | head -50"
    run_cmd "ss -tupn | head -50"
    run_cmd "cat /etc/resolv.conf"
    run_cmd "cat /etc/hosts | grep -v '^#'"
    run_cmd "netstat -rn 2>/dev/null || ip route show"
    
    # Network statistics
    run_cmd "netstat -s 2>/dev/null | head -50 || ss -s"
    run_cmd "ip -s link"
    
    # ARP cache
    run_cmd "ip neigh show"
    run_cmd "arp -a 2>/dev/null || ip neigh"
    
    # Active connections with processes
    echo -e "\n${CYAN}Active network connections with process info...${NC}" | tee -a "$OUTPUT_FILE"
    run_cmd "ss -tulpn"
    run_cmd "lsof -i 2>/dev/null | head -50 || echo 'lsof not available'"
    
    # DNS testing
    echo -e "\n${CYAN}Testing DNS resolution...${NC}" | tee -a "$OUTPUT_FILE"
    run_cmd "nslookup google.com 2>/dev/null || dig google.com 2>/dev/null || echo 'DNS tools not available'"
    
    # Network interfaces details
    run_cmd "ethtool eth0 2>/dev/null || echo 'ethtool not available or no eth0'"
    run_cmd "iwconfig 2>/dev/null || echo 'iwconfig not available'"
fi

# SSH Configuration and Analysis
if [ "$SCAN_SSH_ANALYSIS" = true ]; then
    print_section "SSH CONFIGURATION AND VULNERABILITY ASSESSMENT"
    
    # SSH Service Status
    run_cmd "systemctl status ssh 2>/dev/null || systemctl status sshd 2>/dev/null || service ssh status 2>/dev/null || echo 'SSH service not found'"
    
    # SSH Configuration File
    if [ -f "/etc/ssh/sshd_config" ]; then
        run_cmd "cat /etc/ssh/sshd_config | grep -v '^#' | grep -v '^$'"
        
        # Check for specific SSH vulnerabilities
        echo -e "\n${YELLOW}SSH Security Checks:${NC}" | tee -a "$OUTPUT_FILE"
        
        # Check Protocol version
        if grep -q "^Protocol.*1" /etc/ssh/sshd_config 2>/dev/null; then
            add_vuln "CRITICAL" "SSH Protocol 1 is enabled (highly insecure)" "/etc/ssh/sshd_config"
        fi
        
        # Check PermitRootLogin
        if grep -q "^PermitRootLogin yes" /etc/ssh/sshd_config 2>/dev/null; then
            add_vuln "HIGH" "SSH Root login is permitted" "/etc/ssh/sshd_config"
        fi
        run_cmd "grep -i 'PermitRootLogin' /etc/ssh/sshd_config"
        
        # Check Password Authentication
        if grep -q "^PasswordAuthentication yes" /etc/ssh/sshd_config 2>/dev/null; then
            add_vuln "MEDIUM" "SSH Password authentication is enabled (consider key-based auth)" "/etc/ssh/sshd_config"
        fi
        run_cmd "grep -i 'PasswordAuthentication' /etc/ssh/sshd_config | head -2"
        
        # Check for empty passwords
        if grep -q "^PermitEmptyPasswords yes" /etc/ssh/sshd_config 2>/dev/null; then
            add_vuln "CRITICAL" "SSH permits empty passwords" "/etc/ssh/sshd_config"
        fi
        run_cmd "grep -i 'PermitEmptyPasswords' /etc/ssh/sshd_config"
        
        # Check X11 Forwarding
        if grep -q "^X11Forwarding yes" /etc/ssh/sshd_config 2>/dev/null; then
            add_vuln "LOW" "SSH X11 Forwarding is enabled" "/etc/ssh/sshd_config"
        fi
        
        # Check for weak ciphers
        run_cmd "grep -i 'Ciphers' /etc/ssh/sshd_config"
        
        # Check SSH version
        if command -v sshd &> /dev/null; then
            run_cmd "sshd -V 2>&1 || ssh -V 2>&1"
        fi
    else
        echo "SSH configuration file not found at /etc/ssh/sshd_config" | tee -a "$OUTPUT_FILE"
    fi
    
    # SSH Keys (if accessible)
    print_section "SSH KEYS (Public)"
    if [ -d "/etc/ssh" ]; then
        run_cmd "ls -la /etc/ssh/*.pub 2>/dev/null || echo 'No SSH public keys found in /etc/ssh'"
    fi
    
    # User SSH keys
    if [ -d "$HOME/.ssh" ]; then
        run_cmd "ls -la $HOME/.ssh/"
        run_cmd "cat $HOME/.ssh/authorized_keys 2>/dev/null | wc -l || echo 'No authorized_keys'"
    fi
    
    # Check for SSH agent
    run_cmd "ps aux | grep ssh-agent | grep -v grep"
fi

# User and Authentication
if [ "$SCAN_USERS_AUTH" = true ]; then
    print_section "USER AND AUTHENTICATION"
    run_cmd "whoami"
    run_cmd "id"
    run_cmd "w"
    run_cmd "who -a"
    run_cmd "cat /etc/passwd"
    run_cmd "cat /etc/group"
    run_cmd "last | head -30"
    run_cmd "lastlog | head -20"
    run_cmd "lastb 2>/dev/null | head -20 || echo 'lastb requires root'"
    
    # Password policy
    echo -e "\n${CYAN}Password policy and aging...${NC}" | tee -a "$OUTPUT_FILE"
    run_cmd "cat /etc/login.defs | grep -E 'PASS_MAX_DAYS|PASS_MIN_DAYS|PASS_WARN_AGE'"
    run_cmd "chage -l $(whoami) 2>/dev/null || echo 'Cannot check password aging'"
    
    # Check for users with empty passwords
    echo -e "\n${CYAN}Checking for users with empty passwords...${NC}" | tee -a "$OUTPUT_FILE"
    if is_root; then
        EMPTY_PASS=$(awk -F: '($2 == "" ) { print $1 }' /etc/shadow 2>/dev/null)
        if [ ! -z "$EMPTY_PASS" ]; then
            add_vuln "CRITICAL" "Users with empty passwords found" "$EMPTY_PASS"
        else
            echo "No users with empty passwords found" | tee -a "$OUTPUT_FILE"
        fi
    else
        echo "Root required to check for empty passwords" | tee -a "$OUTPUT_FILE"
    fi
    
    # Check for users with UID 0
    echo -e "\n${CYAN}Checking for non-root users with UID 0...${NC}" | tee -a "$OUTPUT_FILE"
    UID_ZERO=$(awk -F: '($3 == 0 && $1 != "root") { print $1 }' /etc/passwd)
    if [ ! -z "$UID_ZERO" ]; then
        add_vuln "CRITICAL" "Non-root users with UID 0 found" "$UID_ZERO"
    else
        echo "No non-root users with UID 0" | tee -a "$OUTPUT_FILE"
    fi
    
    # Failed login attempts
    echo -e "\n${CYAN}Recent failed login attempts...${NC}" | tee -a "$OUTPUT_FILE"
    run_cmd "grep 'Failed password' /var/log/auth.log 2>/dev/null | tail -20 || grep 'Failed password' /var/log/secure 2>/dev/null | tail -20 || echo 'Cannot access auth logs'"
fi

# Sudo privileges
if [ "$SCAN_USERS_AUTH" = true ]; then
    print_section "SUDO PRIVILEGES"
    run_cmd "sudo -l 2>/dev/null || echo 'Cannot check sudo privileges'"
    
    # Check sudoers file
    if is_root || sudo -n true 2>/dev/null; then
        run_cmd "cat /etc/sudoers 2>/dev/null | grep -v '^#' | grep -v '^$'"
        run_cmd "ls -la /etc/sudoers.d/ 2>/dev/null"
        
        # Check for risky sudo configurations
        if sudo grep -q "NOPASSWD.*ALL" /etc/sudoers /etc/sudoers.d/* 2>/dev/null; then
            add_vuln "HIGH" "NOPASSWD sudo access found" "Check /etc/sudoers"
        fi
    fi
fi

# Firewall Status
if [ "$SCAN_FIREWALL" = true ]; then
    print_section "FIREWALL STATUS"
    run_cmd "iptables -L -n 2>/dev/null || echo 'iptables not available/requires root'"
    run_cmd "iptables -L -n -v 2>/dev/null | head -50"
    run_cmd "ip6tables -L -n 2>/dev/null | head -30"
    run_cmd "ufw status verbose 2>/dev/null || echo 'ufw not available'"
    run_cmd "firewall-cmd --list-all 2>/dev/null || echo 'firewalld not available'"
    run_cmd "nft list ruleset 2>/dev/null || echo 'nftables not available'"
    
    # Check if firewall is active
    if ! iptables -L &>/dev/null && ! ufw status &>/dev/null && ! firewall-cmd --state &>/dev/null; then
        add_vuln "MEDIUM" "No active firewall detected" "System may be exposed"
    fi
fi

# System Hardening Checks
if [ "$SCAN_SYSTEM_HARDENING" = true ]; then
    print_section "SYSTEM HARDENING & SECURITY FEATURES"
    
    # SELinux
    if command -v getenforce &> /dev/null; then
        SELINUX_STATUS=$(getenforce)
        run_cmd "getenforce"
        run_cmd "sestatus"
        if [ "$SELINUX_STATUS" != "Enforcing" ]; then
            add_vuln "MEDIUM" "SELinux is not in enforcing mode" "Current: $SELINUX_STATUS"
        fi
    else
        echo "SELinux not available" | tee -a "$OUTPUT_FILE"
    fi
    
    # AppArmor
    if command -v aa-status &> /dev/null; then
        run_cmd "aa-status 2>/dev/null || echo 'AppArmor not available'"
    else
        echo "AppArmor not available" | tee -a "$OUTPUT_FILE"
    fi
    
    # Kernel security features
    echo -e "\n${CYAN}Kernel security features...${NC}" | tee -a "$OUTPUT_FILE"
    run_cmd "cat /proc/sys/kernel/randomize_va_space"
    run_cmd "cat /proc/sys/kernel/kptr_restrict 2>/dev/null || echo 'kptr_restrict not available'"
    run_cmd "cat /proc/sys/kernel/dmesg_restrict 2>/dev/null || echo 'dmesg_restrict not available'"
    run_cmd "cat /proc/sys/kernel/yama/ptrace_scope 2>/dev/null || echo 'ptrace_scope not available'"
    
    # Check if ASLR is disabled
    ASLR=$(cat /proc/sys/kernel/randomize_va_space 2>/dev/null)
    if [ "$ASLR" = "0" ]; then
        add_vuln "HIGH" "ASLR (Address Space Layout Randomization) is disabled" "/proc/sys/kernel/randomize_va_space"
    fi
fi

# Privilege Escalation Checks
if [ "$SCAN_PRIVILEGE_ESCALATION" = true ]; then
    print_section "PRIVILEGE ESCALATION VECTORS"
    
    # SUID/SGID binaries
    if [ "$CHECK_SUID_SGID" = true ]; then
        echo -e "\n${CYAN}Searching for SUID binaries...${NC}" | tee -a "$OUTPUT_FILE"
        SUID_FILES=$(find / -perm -4000 -type f 2>/dev/null | head -100)
        echo "$SUID_FILES" | tee -a "$OUTPUT_FILE"
        
        # Check for dangerous SUID binaries
        DANGEROUS_SUID="nmap\|vim\|find\|bash\|more\|less\|nano\|cp\|mv\|python\|perl\|ruby\|lua\|php\|gcc\|awk\|tar\|zip"
        FOUND_DANGEROUS=$(echo "$SUID_FILES" | grep -E "$DANGEROUS_SUID")
        if [ ! -z "$FOUND_DANGEROUS" ]; then
            add_vuln "CRITICAL" "Dangerous SUID binaries found (potential privilege escalation)" "$FOUND_DANGEROUS"
        fi
        
        echo -e "\n${CYAN}Searching for SGID binaries...${NC}" | tee -a "$OUTPUT_FILE"
        find / -perm -2000 -type f 2>/dev/null | head -50 | tee -a "$OUTPUT_FILE"
    fi
    
    # World-writable files
    if [ "$CHECK_WORLD_WRITABLE" = true ]; then
        echo -e "\n${CYAN}Searching for world-writable files (excluding /proc, /sys)...${NC}" | tee -a "$OUTPUT_FILE"
        WORLD_WRITABLE=$(find / -path /proc -prune -o -path /sys -prune -o -type f -perm -002 2>/dev/null | head -50)
        echo "$WORLD_WRITABLE" | tee -a "$OUTPUT_FILE"
        
        # Check critical directories
        if echo "$WORLD_WRITABLE" | grep -qE "/etc|/bin|/sbin|/usr/bin|/usr/sbin"; then
            add_vuln "HIGH" "World-writable files found in critical directories" "Check output above"
        fi
        
        echo -e "\n${CYAN}Searching for world-writable directories...${NC}" | tee -a "$OUTPUT_FILE"
        find / -path /proc -prune -o -path /sys -prune -o -type d -perm -002 2>/dev/null | head -50 | tee -a "$OUTPUT_FILE"
    fi
    
    # Files with no owner
    if [ "$CHECK_NO_OWNER" = true ]; then
        echo -e "\n${CYAN}Searching for files with no owner...${NC}" | tee -a "$OUTPUT_FILE"
        NO_OWNER=$(find / -path /proc -prune -o -path /sys -prune -o -nouser -o -nogroup 2>/dev/null | head -30)
        if [ ! -z "$NO_OWNER" ]; then
            echo "$NO_OWNER" | tee -a "$OUTPUT_FILE"
            add_vuln "LOW" "Files with no owner/group found" "Could be from removed users"
        else
            echo "No files without owner found" | tee -a "$OUTPUT_FILE"
        fi
    fi
    
    # Writable /etc/passwd or /etc/shadow
    if [ "$CHECK_WEAK_PERMISSIONS" = true ]; then
        echo -e "\n${CYAN}Checking critical file permissions...${NC}" | tee -a "$OUTPUT_FILE"
        run_cmd "ls -la /etc/passwd /etc/shadow /etc/sudoers 2>/dev/null"
        
        if [ -w /etc/passwd ]; then
            add_vuln "CRITICAL" "/etc/passwd is writable by current user" "Immediate privilege escalation possible"
        fi
        
        if [ -w /etc/shadow ]; then
            add_vuln "CRITICAL" "/etc/shadow is writable by current user" "Immediate privilege escalation possible"
        fi
        
        if [ -r /etc/shadow ]; then
            add_vuln "HIGH" "/etc/shadow is readable by current user" "Password hashes exposed"
        fi
    fi
    
    # Check for sudo misconfigurations
    if [ "$CHECK_SUDO_MISCONFIG" = true ]; then
        echo -e "\n${CYAN}Checking for sudo privilege escalation vectors...${NC}" | tee -a "$OUTPUT_FILE"
        SUDO_L=$(sudo -l 2>/dev/null)
        echo "$SUDO_L" | tee -a "$OUTPUT_FILE"
        
        # Check for dangerous sudo commands
        if echo "$SUDO_L" | grep -qE "NOPASSWD.*ALL|ALL.*NOPASSWD"; then
            add_vuln "CRITICAL" "User can run ALL commands with NOPASSWD" "sudo -l output"
        fi
        
        if echo "$SUDO_L" | grep -qE "\(ALL\).*ALL"; then
            add_vuln "HIGH" "User has broad sudo privileges" "sudo -l output"
        fi
        
        # Check for specific dangerous sudo binaries
        if echo "$SUDO_L" | grep -qE "vim|vi|find|awk|perl|python|ruby|less|more|man|ftp"; then
            add_vuln "HIGH" "Sudo access to dangerous binaries that can escape to shell" "sudo -l output"
        fi
    fi
    
    # Kernel exploit detection
    if [ "$CHECK_KERNEL_EXPLOITS" = true ]; then
        echo -e "\n${CYAN}Checking kernel version against known vulnerabilities...${NC}" | tee -a "$OUTPUT_FILE"
        KERNEL_VERSION=$(uname -r)
        echo "Kernel version: $KERNEL_VERSION" | tee -a "$OUTPUT_FILE"
        
        # Check for very old kernels
        KERNEL_MAJOR=$(echo $KERNEL_VERSION | cut -d. -f1)
        KERNEL_MINOR=$(echo $KERNEL_VERSION | cut -d. -f2)
        
        if [ "$KERNEL_MAJOR" -lt 4 ]; then
            add_vuln "HIGH" "Kernel version is very old and likely vulnerable" "$KERNEL_VERSION"
        elif [ "$KERNEL_MAJOR" -eq 4 ] && [ "$KERNEL_MINOR" -lt 9 ]; then
            add_vuln "MEDIUM" "Kernel version is old, consider upgrading" "$KERNEL_VERSION"
        fi
        
        # Check for Dirty COW vulnerability (CVE-2016-5195)
        if [ "$KERNEL_MAJOR" -lt 4 ] || ([ "$KERNEL_MAJOR" -eq 4 ] && [ "$KERNEL_MINOR" -lt 8 ]); then
            add_vuln "CRITICAL" "Kernel may be vulnerable to Dirty COW (CVE-2016-5195)" "$KERNEL_VERSION"
        fi
    fi
    
    # Capabilities
    echo -e "\n${CYAN}Checking for files with capabilities...${NC}" | tee -a "$OUTPUT_FILE"
    if command -v getcap &> /dev/null; then
        CAP_FILES=$(getcap -r / 2>/dev/null)
        echo "$CAP_FILES" | tee -a "$OUTPUT_FILE"
        
        if echo "$CAP_FILES" | grep -q "cap_setuid"; then
            add_vuln "HIGH" "Files with cap_setuid capability found (potential privilege escalation)" "$CAP_FILES"
        fi
    else
        echo "getcap not available" | tee -a "$OUTPUT_FILE"
    fi
    
    # Check PATH for writable directories
    echo -e "\n${CYAN}Checking PATH for writable directories...${NC}" | tee -a "$OUTPUT_FILE"
    echo "PATH: $PATH" | tee -a "$OUTPUT_FILE"
    for dir in $(echo $PATH | tr ':' ' '); do
        if [ -w "$dir" 2>/dev/null ]; then
            add_vuln "HIGH" "Writable directory in PATH: $dir" "Could allow binary hijacking"
        fi
    done
fi

# Container Detection
if [ "$SCAN_CONTAINERS" = true ]; then
    print_section "CONTAINER DETECTION"
    
    # Docker
    if command -v docker &> /dev/null; then
        echo -e "${CYAN}Docker detected${NC}" | tee -a "$OUTPUT_FILE"
        run_cmd "docker --version"
        run_cmd "docker ps -a 2>/dev/null || echo 'Cannot access Docker (permissions?)'"
        run_cmd "docker images 2>/dev/null | head -20"
        run_cmd "docker network ls 2>/dev/null"
        run_cmd "docker volume ls 2>/dev/null"
        
        # Check if we're in a container
        if [ -f "/.dockerenv" ]; then
            echo -e "${YELLOW}System is running inside a Docker container${NC}" | tee -a "$OUTPUT_FILE"
        fi
        
        # Check Docker security
        if docker info 2>/dev/null | grep -q "live-restore"; then
            echo "Docker live-restore enabled" | tee -a "$OUTPUT_FILE"
        fi
    else
        echo "Docker not installed" | tee -a "$OUTPUT_FILE"
    fi
    
    # Podman
    if command -v podman &> /dev/null; then
        echo -e "${CYAN}Podman detected${NC}" | tee -a "$OUTPUT_FILE"
        run_cmd "podman --version"
        run_cmd "podman ps -a 2>/dev/null"
        run_cmd "podman images 2>/dev/null | head -20"
    fi
    
    # Kubernetes
    if command -v kubectl &> /dev/null; then
        echo -e "${CYAN}kubectl detected${NC}" | tee -a "$OUTPUT_FILE"
        run_cmd "kubectl version --client 2>/dev/null"
        run_cmd "kubectl get nodes 2>/dev/null || echo 'Not connected to cluster'"
        run_cmd "kubectl get pods --all-namespaces 2>/dev/null | head -20"
    fi
    
    # LXC/LXD
    if command -v lxc &> /dev/null; then
        echo -e "${CYAN}LXC/LXD detected${NC}" | tee -a "$OUTPUT_FILE"
        run_cmd "lxc --version"
        run_cmd "lxc list 2>/dev/null"
    fi
fi

# Database Detection
if [ "$SCAN_DATABASES" = true ]; then
    print_section "DATABASE DETECTION"
    
    # MySQL/MariaDB
    if command -v mysql &> /dev/null || systemctl status mysql &>/dev/null || systemctl status mariadb &>/dev/null; then
        echo -e "${CYAN}MySQL/MariaDB detected${NC}" | tee -a "$OUTPUT_FILE"
        run_cmd "mysql --version 2>/dev/null || mariadb --version 2>/dev/null"
        run_cmd "systemctl status mysql 2>/dev/null || systemctl status mariadb 2>/dev/null"
        run_cmd "mysqladmin version 2>/dev/null || echo 'Cannot access MySQL'"
        
        # Check for default MySQL port
        if ss -tuln | grep -q ":3306"; then
            echo "MySQL listening on port 3306" | tee -a "$OUTPUT_FILE"
            if ss -tuln | grep ":3306" | grep -q "0.0.0.0"; then
                add_vuln "MEDIUM" "MySQL listening on all interfaces" "Consider binding to localhost only"
            fi
        fi
    fi
    
    # PostgreSQL
    if command -v psql &> /dev/null || systemctl status postgresql &>/dev/null; then
        echo -e "${CYAN}PostgreSQL detected${NC}" | tee -a "$OUTPUT_FILE"
        run_cmd "psql --version"
        run_cmd "systemctl status postgresql 2>/dev/null"
        
        # Check for default PostgreSQL port
        if ss -tuln | grep -q ":5432"; then
            echo "PostgreSQL listening on port 5432" | tee -a "$OUTPUT_FILE"
            if ss -tuln | grep ":5432" | grep -q "0.0.0.0"; then
                add_vuln "MEDIUM" "PostgreSQL listening on all interfaces" "Consider binding to localhost only"
            fi
        fi
    fi
    
    # MongoDB
    if command -v mongo &> /dev/null || command -v mongod &> /dev/null || systemctl status mongod &>/dev/null; then
        echo -e "${CYAN}MongoDB detected${NC}" | tee -a "$OUTPUT_FILE"
        run_cmd "mongo --version 2>/dev/null || mongod --version 2>/dev/null"
        run_cmd "systemctl status mongod 2>/dev/null"
        
        # Check for default MongoDB port
        if ss -tuln | grep -q ":27017"; then
            echo "MongoDB listening on port 27017" | tee -a "$OUTPUT_FILE"
            if ss -tuln | grep ":27017" | grep -q "0.0.0.0"; then
                add_vuln "HIGH" "MongoDB listening on all interfaces without authentication" "Critical security risk"
            fi
        fi
    fi
    
    # Redis
    if command -v redis-cli &> /dev/null || systemctl status redis &>/dev/null; then
        echo -e "${CYAN}Redis detected${NC}" | tee -a "$OUTPUT_FILE"
        run_cmd "redis-cli --version 2>/dev/null"
        run_cmd "systemctl status redis 2>/dev/null || systemctl status redis-server 2>/dev/null"
        
        # Check for default Redis port
        if ss -tuln | grep -q ":6379"; then
            echo "Redis listening on port 6379" | tee -a "$OUTPUT_FILE"
            if ss -tuln | grep ":6379" | grep -q "0.0.0.0"; then
                add_vuln "CRITICAL" "Redis listening on all interfaces" "Severe security risk - immediate action required"
            fi
        fi
    fi
fi

# Web Server Detection
if [ "$SCAN_WEB_SERVERS" = true ]; then
    print_section "WEB SERVER DETECTION"
    
    # Apache
    if command -v apache2 &> /dev/null || command -v httpd &> /dev/null; then
        echo -e "${CYAN}Apache detected${NC}" | tee -a "$OUTPUT_FILE"
        run_cmd "apache2 -v 2>/dev/null || httpd -v 2>/dev/null"
        run_cmd "systemctl status apache2 2>/dev/null || systemctl status httpd 2>/dev/null"
        run_cmd "apache2ctl -M 2>/dev/null | head -30 || httpd -M 2>/dev/null | head -30"
    fi
    
    # Nginx
    if command -v nginx &> /dev/null; then
        echo -e "${CYAN}Nginx detected${NC}" | tee -a "$OUTPUT_FILE"
        run_cmd "nginx -v 2>&1"
        run_cmd "systemctl status nginx 2>/dev/null"
        run_cmd "nginx -T 2>/dev/null | head -50 || echo 'Cannot read nginx config'"
    fi
    
    # Lighttpd
    if command -v lighttpd &> /dev/null; then
        echo -e "${CYAN}Lighttpd detected${NC}" | tee -a "$OUTPUT_FILE"
        run_cmd "lighttpd -v"
        run_cmd "systemctl status lighttpd 2>/dev/null"
    fi
    
    # Check for web ports
    echo -e "\n${CYAN}Checking common web ports...${NC}" | tee -a "$OUTPUT_FILE"
    for port in 80 443 8080 8443; do
        if ss -tuln | grep -q ":$port "; then
            echo "Port $port is listening" | tee -a "$OUTPUT_FILE"
        fi
    done
fi

# Local Network Discovery
if [ "$SCAN_NETWORK_DISCOVERY" = true ]; then
    print_section "LOCAL NETWORK DISCOVERY"
    
    # Get local network information
    run_cmd "ip route | grep -E 'default|0.0.0.0/0'"
    
    # Function to perform network scan
    perform_network_scan() {
        local network_range=$1
        echo -e "\n${YELLOW}Scanning network: $network_range${NC}" | tee -a "$OUTPUT_FILE"
        
        # Check if nmap is available
        if command -v nmap &> /dev/null; then
            echo "Using nmap for network discovery..." | tee -a "$OUTPUT_FILE"
            run_cmd "nmap -sn -T4 $network_range 2>/dev/null | head -100"
            run_cmd "nmap -sV -T4 --top-ports 10 $network_range 2>/dev/null | head -100"
        else
            echo "nmap not available, using ping sweep..." | tee -a "$OUTPUT_FILE"
            
            # Extract base network
            local base_network=$(echo $network_range | cut -d'/' -f1 | rev | cut -d'.' -f2- | rev)
            
            # Controlled ping sweep with limited threads
            local count=0
            for i in {1..254}; do
                if [ $count -ge $NETWORK_SCAN_THREADS ]; then
                    wait -n 2>/dev/null
                    count=$((count - 1))
                fi
                
                (ping -c 1 -W $NETWORK_SCAN_TIMEOUT "${base_network}.${i}" 2>/dev/null | grep "bytes from" | cut -d" " -f4 | tr -d ":") &
                count=$((count + 1))
            done
            wait
        fi
    }
    
    # Try to detect and scan local network
    detect_local_network() {
        local gateway=$(ip route | grep default | awk '{print $3}' | head -1)
        if [ ! -z "$gateway" ]; then
            local network=$(echo $gateway | cut -d. -f1-3)
            echo "Detected local network: ${network}.0/24" | tee -a "$OUTPUT_FILE"
            perform_network_scan "${network}.0/24"
        else
            echo "Could not detect local network automatically" | tee -a "$OUTPUT_FILE"
        fi
    }
    
    detect_local_network
fi

# Open Ports on Local System
if [ "$SCAN_NETWORK" = true ]; then
    print_section "LOCAL SYSTEM OPEN PORTS"
    run_cmd "ss -tulnp"
    run_cmd "netstat -tulnp 2>/dev/null | head -50 || echo 'netstat not available'"
    
    # Check for suspicious ports
    echo -e "\n${CYAN}Analyzing open ports for security issues...${NC}" | tee -a "$OUTPUT_FILE"
    
    # Check for well-known vulnerable ports
    if ss -tuln | grep -qE ":23 |:21 |:69 |:512 |:513 |:514 "; then
        add_vuln "HIGH" "Insecure services detected (telnet/ftp/tftp/rsh)" "These protocols transmit data in plaintext"
    fi
    
    # Check for database ports exposed
    if ss -tuln | grep -E ":3306 |:5432 |:27017 |:6379 " | grep -q "0.0.0.0"; then
        add_vuln "HIGH" "Database ports exposed on all interfaces" "Databases should be bound to localhost"
    fi
fi

# Open Ports on Local System
print_section "LOCAL SYSTEM OPEN PORTS"
run_cmd "ss -tulnp | head -30"

# System Logs (recent entries)
if [ "$SCAN_LOGS" = true ]; then
    print_section "RECENT SYSTEM LOGS"
    run_cmd "dmesg | tail -30 2>/dev/null || echo 'dmesg requires root'"
    run_cmd "journalctl --no-pager -n 50 2>/dev/null || tail -50 /var/log/syslog 2>/dev/null || tail -50 /var/log/messages 2>/dev/null || echo 'System logs not accessible'"
    
    # Authentication logs
    echo -e "\n${CYAN}Recent authentication events...${NC}" | tee -a "$OUTPUT_FILE"
    run_cmd "journalctl --no-pager -u ssh -n 30 2>/dev/null || tail -30 /var/log/auth.log 2>/dev/null || tail -30 /var/log/secure 2>/dev/null || echo 'Auth logs not accessible'"
    
    # Kernel messages
    echo -e "\n${CYAN}Recent kernel messages...${NC}" | tee -a "$OUTPUT_FILE"
    run_cmd "journalctl --no-pager -k -n 20 2>/dev/null || dmesg | tail -20 2>/dev/null"
    
    # System errors
    echo -e "\n${CYAN}Recent errors in logs...${NC}" | tee -a "$OUTPUT_FILE"
    run_cmd "journalctl --no-pager -p err -n 20 2>/dev/null || grep -i error /var/log/syslog 2>/dev/null | tail -20 || echo 'Cannot check error logs'"
fi

# Cron Jobs
if [ "$SCAN_CRON_SCHEDULED" = true ]; then
    print_section "SCHEDULED TASKS (CRON JOBS)"
    run_cmd "crontab -l 2>/dev/null || echo 'No user crontab'"
    
    # System-wide cron jobs
    echo -e "\n${CYAN}System-wide cron jobs...${NC}" | tee -a "$OUTPUT_FILE"
    run_cmd "ls -la /etc/cron* 2>/dev/null"
    run_cmd "cat /etc/crontab 2>/dev/null"
    
    for dir in /etc/cron.hourly /etc/cron.daily /etc/cron.weekly /etc/cron.monthly; do
        if [ -d "$dir" ]; then
            echo -e "\n${YELLOW}Contents of $dir:${NC}" | tee -a "$OUTPUT_FILE"
            run_cmd "ls -la $dir"
        fi
    done
    
    # All user crontabs
    if is_root; then
        echo -e "\n${CYAN}All user crontabs...${NC}" | tee -a "$OUTPUT_FILE"
        for user in $(cut -f1 -d: /etc/passwd); do
            CRON=$(crontab -u $user -l 2>/dev/null)
            if [ ! -z "$CRON" ]; then
                echo "Crontab for $user:" | tee -a "$OUTPUT_FILE"
                echo "$CRON" | tee -a "$OUTPUT_FILE"
            fi
        done
    fi
    
    # Systemd timers
    echo -e "\n${CYAN}Systemd timers...${NC}" | tee -a "$OUTPUT_FILE"
    run_cmd "systemctl list-timers --all 2>/dev/null | head -30"
    
    # At jobs
    run_cmd "atq 2>/dev/null || echo 'at not available'"
fi

# Environment Variables
print_section "ENVIRONMENT VARIABLES"
run_cmd "printenv | sort"
run_cmd "env | grep -E '(PATH|HOME|USER|SHELL|TERM|LANG)'"

# Vulnerability Scoring Summary
if [ "$SCAN_VULNERABILITY_SCORING" = true ]; then
    print_section "VULNERABILITY ASSESSMENT SUMMARY"
    
    echo -e "\n${CYAN}╔════════════════════════════════════════════════════════════╗${NC}" | tee -a "$OUTPUT_FILE"
    echo -e "${CYAN}║           AUTOMATED VULNERABILITY SCORING                  ║${NC}" | tee -a "$OUTPUT_FILE"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}" | tee -a "$OUTPUT_FILE"
    
    echo "" | tee -a "$OUTPUT_FILE"
    echo "Total Vulnerability Score: $VULN_SCORE" | tee -a "$OUTPUT_FILE"
    echo "" | tee -a "$OUTPUT_FILE"
    echo -e "${RED}Critical Issues: $VULN_CRITICAL${NC}" | tee -a "$OUTPUT_FILE"
    echo -e "${YELLOW}High Issues: $VULN_HIGH${NC}" | tee -a "$OUTPUT_FILE"
    echo -e "${BLUE}Medium Issues: $VULN_MEDIUM${NC}" | tee -a "$OUTPUT_FILE"
    echo -e "${GREEN}Low Issues: $VULN_LOW${NC}" | tee -a "$OUTPUT_FILE"
    echo "" | tee -a "$OUTPUT_FILE"
    
    # Risk assessment
    if [ $VULN_CRITICAL -gt 0 ]; then
        RISK_LEVEL="CRITICAL"
        RISK_COLOR=$RED
    elif [ $VULN_HIGH -gt 3 ]; then
        RISK_LEVEL="HIGH"
        RISK_COLOR=$RED
    elif [ $VULN_HIGH -gt 0 ] || [ $VULN_MEDIUM -gt 5 ]; then
        RISK_LEVEL="ELEVATED"
        RISK_COLOR=$YELLOW
    elif [ $VULN_MEDIUM -gt 0 ]; then
        RISK_LEVEL="MODERATE"
        RISK_COLOR=$YELLOW
    else
        RISK_LEVEL="LOW"
        RISK_COLOR=$GREEN
    fi
    
    echo -e "${RISK_COLOR}Overall Risk Level: $RISK_LEVEL${NC}" | tee -a "$OUTPUT_FILE"
    echo "" | tee -a "$OUTPUT_FILE"
    
    # Recommendations
    echo -e "${CYAN}Priority Recommendations:${NC}" | tee -a "$OUTPUT_FILE"
    if [ $VULN_CRITICAL -gt 0 ]; then
        echo "1. IMMEDIATE ACTION REQUIRED: Address critical vulnerabilities" | tee -a "$OUTPUT_FILE"
    fi
    if [ $VULN_HIGH -gt 0 ]; then
        echo "2. HIGH PRIORITY: Review and mitigate high-severity issues" | tee -a "$OUTPUT_FILE"
    fi
    if [ $VULN_MEDIUM -gt 0 ]; then
        echo "3. MEDIUM PRIORITY: Address medium-severity findings" | tee -a "$OUTPUT_FILE"
    fi
    echo "4. Review all findings in detail in the full report" | tee -a "$OUTPUT_FILE"
    echo "5. Keep system and software updated" | tee -a "$OUTPUT_FILE"
    echo "6. Implement defense-in-depth security controls" | tee -a "$OUTPUT_FILE"
fi

# Summary
print_section "SCAN SUMMARY"
SCAN_END_TIME=$(date)
run_cmd "date"
echo -e "${GREEN}Scan completed successfully${NC}" | tee -a "$OUTPUT_FILE"
echo "Scan ended at: $SCAN_END_TIME" | tee -a "$OUTPUT_FILE"
echo -e "${GREEN}Full output saved to: $OUTPUT_FILE${NC}"
echo -e "${YELLOW}Total file size: $(du -h $OUTPUT_FILE | cut -f1)${NC}"

# Display configuration summary
echo -e "\n${CYAN}Scan Configuration:${NC}" | tee -a "$OUTPUT_FILE"
echo "Basic System Scan: $SCAN_BASIC_SYSTEM" | tee -a "$OUTPUT_FILE"
echo "Hardware Detailed: $SCAN_HARDWARE_DETAILED" | tee -a "$OUTPUT_FILE"
echo "Network Scan: $SCAN_NETWORK" | tee -a "$OUTPUT_FILE"
echo "Network Discovery: $SCAN_NETWORK_DISCOVERY" | tee -a "$OUTPUT_FILE"
echo "Services: $SCAN_SERVICES" | tee -a "$OUTPUT_FILE"
echo "Users/Auth: $SCAN_USERS_AUTH" | tee -a "$OUTPUT_FILE"
echo "SSH Analysis: $SCAN_SSH_ANALYSIS" | tee -a "$OUTPUT_FILE"
echo "Firewall: $SCAN_FIREWALL" | tee -a "$OUTPUT_FILE"
echo "Software: $SCAN_SOFTWARE" | tee -a "$OUTPUT_FILE"
echo "Storage: $SCAN_STORAGE" | tee -a "$OUTPUT_FILE"
echo "Security Audit: $SCAN_SECURITY_AUDIT" | tee -a "$OUTPUT_FILE"
echo "Privilege Escalation: $SCAN_PRIVILEGE_ESCALATION" | tee -a "$OUTPUT_FILE"
echo "Containers: $SCAN_CONTAINERS" | tee -a "$OUTPUT_FILE"
echo "Databases: $SCAN_DATABASES" | tee -a "$OUTPUT_FILE"
echo "Web Servers: $SCAN_WEB_SERVERS" | tee -a "$OUTPUT_FILE"
echo "System Hardening: $SCAN_SYSTEM_HARDENING" | tee -a "$OUTPUT_FILE"
echo "Logs: $SCAN_LOGS" | tee -a "$OUTPUT_FILE"
echo "Cron/Scheduled: $SCAN_CRON_SCHEDULED" | tee -a "$OUTPUT_FILE"
echo "Vulnerability Scoring: $SCAN_VULNERABILITY_SCORING" | tee -a "$OUTPUT_FILE"
echo "Performance: $SCAN_PERFORMANCE" | tee -a "$OUTPUT_FILE"

# Display important findings
echo -e "\n${RED}╔════════════════════════════════════════════════════════════╗${NC}" | tee -a "$OUTPUT_FILE"
echo -e "${RED}║              QUICK SECURITY ASSESSMENT                     ║${NC}" | tee -a "$OUTPUT_FILE"
echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}" | tee -a "$OUTPUT_FILE"
echo "" | tee -a "$OUTPUT_FILE"
echo -e "${YELLOW}Manual Review Required:${NC}" | tee -a "$OUTPUT_FILE"
echo "1. Review all vulnerability findings above" | tee -a "$OUTPUT_FILE"
echo "2. Check SSH configuration for weak settings" | tee -a "$OUTPUT_FILE"
echo "3. Verify unnecessary open ports are closed" | tee -a "$OUTPUT_FILE"
echo "4. Review user accounts and privileges" | tee -a "$OUTPUT_FILE"
echo "5. Audit running services for necessity" | tee -a "$OUTPUT_FILE"
echo "6. Review SUID/SGID binaries and file permissions" | tee -a "$OUTPUT_FILE"
echo "7. Ensure all software is up-to-date" | tee -a "$OUTPUT_FILE"
echo "8. Verify firewall rules are appropriate" | tee -a "$OUTPUT_FILE"
echo "9. Check system hardening features (SELinux/AppArmor)" | tee -a "$OUTPUT_FILE"
echo "10. Review logs for suspicious activity" | tee -a "$OUTPUT_FILE"
echo "" | tee -a "$OUTPUT_FILE"

if [ "$SCAN_VULNERABILITY_SCORING" = true ]; then
    echo -e "${RISK_COLOR}OVERALL RISK: $RISK_LEVEL${NC}" | tee -a "$OUTPUT_FILE"
    echo -e "${CYAN}Vulnerability Breakdown: Critical=$VULN_CRITICAL High=$VULN_HIGH Medium=$VULN_MEDIUM Low=$VULN_LOW${NC}" | tee -a "$OUTPUT_FILE"
fi

echo "" | tee -a "$OUTPUT_FILE"
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Scan Complete - Report saved to: $OUTPUT_FILE${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"