# Looter - Comprehensive Security Audit & System Scanner

A fully automated bash script for comprehensive Linux system reconnaissance, security auditing, and vulnerability assessment. Designed for security professionals, system administrators, and penetration testers performing authorized security assessments.

## ⚠️ Legal Disclaimer

**FOR AUTHORIZED USE ONLY**

This tool is intended solely for:
- Security audits on systems you own
- Authorized penetration testing with written permission
- Educational purposes in controlled lab environments
- System administration of your own infrastructure

**Unauthorized access to computer systems is illegal.** Users are responsible for obtaining proper authorization before running this tool. Misuse may violate laws including the Computer Fraud and Abuse Act (CFAA), Computer Misuse Act, or similar legislation in your jurisdiction.

## 🚀 Features

### Modular Scan Configuration
- **20+ toggleable scan modules** - Enable only what you need
- **No user interaction required** - Fully automated operation
- **Comprehensive reporting** - Detailed output with timestamps
- **Automated vulnerability scoring** - Risk assessment with prioritized recommendations

### Core Capabilities

#### 🔐 Security & Vulnerability Assessment
- **Automated vulnerability scoring** (CRITICAL → LOW)
- **Overall risk level calculation**
- SSH security analysis with specific CVE checks
- Firewall configuration assessment
- System hardening verification (SELinux, AppArmor, ASLR)
- Password policy and authentication analysis
- Open port security evaluation

#### 🎯 Privilege Escalation Detection
- SUID/SGID binary enumeration (flags dangerous executables)
- World-writable file detection in critical directories
- Weak file permission analysis (/etc/passwd, /etc/shadow)
- Sudo misconfiguration detection (NOPASSWD, overly permissive rules)
- Kernel exploit identification (Dirty COW, version checks)
- Linux capability analysis (cap_setuid, etc.)
- PATH hijacking vulnerability detection
- Files with no owner/group

#### 🖥️ System Information
- Complete hardware enumeration (CPU, Memory, USB, PCI devices)
- BIOS/UEFI firmware information
- Kernel version and loaded modules
- System manufacturer and product details
- Performance metrics (CPU, memory, I/O)
- Storage analysis with SMART disk health

#### 🌐 Network Analysis
- Network interface configuration (IPv4/IPv6)
- Active connections with process mapping
- Local network host discovery (nmap or ping sweep)
- ARP cache and routing tables
- DNS configuration and testing
- Open port enumeration with security flags
- Network statistics and interface details

#### 📦 Application Detection
- **Containers**: Docker, Podman, Kubernetes, LXC/LXD
- **Databases**: MySQL, PostgreSQL, MongoDB, Redis
- **Web Servers**: Apache, Nginx, Lighttpd
- **Package Managers**: apt, yum, pacman, snap, flatpak
- Security update availability
- Installed software inventory

#### 👥 User & Authentication
- User and group enumeration
- Login history and current sessions
- Failed login attempt tracking
- Password aging and policy analysis
- Empty password detection
- Non-root UID 0 user detection
- Sudo privilege enumeration
- SSH key inventory

#### 📊 System Monitoring
- Running processes (CPU/Memory sorted)
- Systemd service enumeration
- Zombie process detection
- Process tree visualization
- System logs (dmesg, journalctl, auth logs)
- Cron jobs and systemd timers
- At jobs and scheduled tasks

## 📋 Requirements

- Linux/Unix operating system
- Bash shell
- Root privileges (recommended for complete scan coverage)

### Optional Tools (auto-detected)
- `nmap` - Enhanced network discovery
- `smartctl` - Disk health monitoring
- `lshw` - Detailed hardware information
- `dmidecode` - BIOS/SMBIOS information
- `ethtool` - Network interface details

## 🔧 Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/Looter.git
cd Looter

# Make executable
chmod +x system_scan.sh

# Run the scan
sudo ./system_scan.sh
```

## ⚙️ Configuration

Edit the configuration variables at the top of `system_scan.sh` to customize your scan:

```bash
# ============================================================================
# CONFIGURATION SECTION - Enable/Disable Scan Modules
# ============================================================================

# Main Scan Modules
SCAN_BASIC_SYSTEM=true              # System info, hardware, kernel
SCAN_HARDWARE_DETAILED=true         # Detailed hardware enumeration
SCAN_NETWORK=true                   # Network configuration
SCAN_NETWORK_DISCOVERY=true         # Local network host discovery
SCAN_SERVICES=true                  # Running services and processes
SCAN_USERS_AUTH=true                # Users, groups, authentication
SCAN_SSH_ANALYSIS=true              # SSH configuration and vulnerabilities
SCAN_FIREWALL=true                  # Firewall rules and status
SCAN_SOFTWARE=true                  # Installed packages
SCAN_STORAGE=true                   # Disk, filesystem, mount points
SCAN_SECURITY_AUDIT=true            # SUID/SGID, world-writable files
SCAN_PRIVILEGE_ESCALATION=true      # Privilege escalation vectors
SCAN_CONTAINERS=true                # Docker, Podman detection
SCAN_DATABASES=true                 # Database detection
SCAN_WEB_SERVERS=true               # Web server detection
SCAN_SYSTEM_HARDENING=true          # SELinux, AppArmor
SCAN_LOGS=true                      # System logs
SCAN_CRON_SCHEDULED=true            # Cron jobs and timers
SCAN_VULNERABILITY_SCORING=true     # Automated vulnerability assessment
SCAN_PERFORMANCE=true               # Performance metrics

# Privilege Escalation Checks
CHECK_SUID_SGID=true                # Find SUID/SGID binaries
CHECK_WORLD_WRITABLE=true           # Find world-writable files
CHECK_NO_OWNER=true                 # Find files with no owner
CHECK_WEAK_PERMISSIONS=true         # Check for weak file permissions
CHECK_SUDO_MISCONFIG=true           # Check sudo misconfigurations
CHECK_KERNEL_EXPLOITS=true          # Check for known kernel vulnerabilities

# Network Settings
NETWORK_SCAN_TIMEOUT=1              # Ping timeout in seconds
NETWORK_SCAN_THREADS=50             # Max concurrent ping threads
```

## 📖 Usage Examples

### Full Security Audit
```bash
# Run complete scan with all modules (requires root)
sudo ./system_scan.sh
```

### Quick System Overview
```bash
# Edit script to enable only basic modules
SCAN_BASIC_SYSTEM=true
SCAN_NETWORK=true
SCAN_SERVICES=true
# Set all others to false

./system_scan.sh
```

### Privilege Escalation Focus
```bash
# Enable only privilege escalation checks
SCAN_PRIVILEGE_ESCALATION=true
CHECK_SUID_SGID=true
CHECK_WORLD_WRITABLE=true
CHECK_WEAK_PERMISSIONS=true
CHECK_SUDO_MISCONFIG=true
CHECK_KERNEL_EXPLOITS=true

sudo ./system_scan.sh
```

### Network-Only Scan
```bash
# Enable network modules
SCAN_NETWORK=true
SCAN_NETWORK_DISCOVERY=true
NETWORK_SCAN_THREADS=100

./system_scan.sh
```

## 📊 Output

The script generates a timestamped report file: `system_scan_YYYY-MM-DD_HH-MM-SS.txt`

### Sample Output Structure

```
╔════════════════════════════════════════════════════════════╗
║     COMPREHENSIVE SECURITY AUDIT & SYSTEM SCANNER         ║
╚════════════════════════════════════════════════════════════╝

=== SYSTEM INFORMATION ===
[Detailed system information...]

=== PRIVILEGE ESCALATION VECTORS ===
[CRITICAL] Dangerous SUID binaries found
[HIGH] Sudo access to dangerous binaries
[MEDIUM] World-writable files in /tmp

╔════════════════════════════════════════════════════════════╗
║           AUTOMATED VULNERABILITY SCORING                  ║
╚════════════════════════════════════════════════════════════╝

Total Vulnerability Score: 34

Critical Issues: 2
High Issues: 5
Medium Issues: 8
Low Issues: 3

Overall Risk Level: CRITICAL

Priority Recommendations:
1. IMMEDIATE ACTION REQUIRED: Address critical vulnerabilities
2. HIGH PRIORITY: Review and mitigate high-severity issues
3. MEDIUM PRIORITY: Address medium-severity findings
```

## 🎯 Vulnerability Scoring

### Severity Levels
- **CRITICAL** (10 points) - Immediate exploitation risk
  - SSH Protocol 1 enabled
  - Empty passwords allowed
  - World-writable /etc/passwd or /etc/shadow
  - Dangerous SUID binaries (vim, find, bash, nmap)
  - Redis/MongoDB exposed on all interfaces
  - Dirty COW kernel vulnerability

- **HIGH** (7 points) - Significant security risk
  - SSH root login permitted
  - Writable PATH directories
  - NOPASSWD sudo access
  - cap_setuid capabilities
  - Very old kernel versions
  - Databases exposed on all interfaces

- **MEDIUM** (4 points) - Should be addressed
  - SSH password authentication enabled
  - No active firewall
  - SELinux not enforcing
  - Services on all interfaces

- **LOW** (1 point) - Minor issues
  - X11 forwarding enabled
  - Files with no owner

### Risk Levels
- **CRITICAL** - Any critical vulnerabilities
- **HIGH** - 3+ high vulnerabilities
- **ELEVATED** - Any high or 5+ medium vulnerabilities
- **MODERATE** - Any medium vulnerabilities
- **LOW** - Only low or no vulnerabilities

## 🛡️ Security Checks Performed

### System Hardening
- ✅ SELinux enforcement status
- ✅ AppArmor profile status
- ✅ ASLR (Address Space Layout Randomization)
- ✅ Kernel pointer restriction
- ✅ dmesg restriction
- ✅ ptrace scope

### Authentication & Access
- ✅ Password policies and aging
- ✅ Empty password detection
- ✅ Non-root UID 0 users
- ✅ Failed login attempts
- ✅ Sudo privilege analysis
- ✅ SSH configuration hardening

### Network Security
- ✅ Firewall active status
- ✅ Open port analysis
- ✅ Insecure protocol detection (telnet, FTP)
- ✅ Database exposure checks
- ✅ Service binding analysis

### File System Security
- ✅ SUID/SGID binary enumeration
- ✅ World-writable file detection
- ✅ Critical file permissions
- ✅ Orphaned files (no owner/group)
- ✅ Linux capabilities

## 🤝 Contributing

Contributions are welcome! Please ensure all contributions are for legitimate security purposes.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/enhancement`)
3. Commit your changes (`git commit -am 'Add new security check'`)
4. Push to the branch (`git push origin feature/enhancement`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## ⚖️ Responsible Use

This tool is provided for educational and professional security assessment purposes only. Always:

- ✅ Obtain written authorization before scanning any system
- ✅ Use in controlled lab environments for learning
- ✅ Follow responsible disclosure practices
- ✅ Comply with all applicable laws and regulations
- ❌ Never use on systems without explicit permission
- ❌ Do not use for malicious purposes

**The authors assume no liability for misuse of this tool.**

## 🔗 Resources

- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/)
- [Linux Privilege Escalation](https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Methodology%20and%20Resources/Linux%20-%20Privilege%20Escalation.md)

## 📧 Contact

For security issues or questions about authorized use, please open an issue on GitHub.

---

**Remember: With great power comes great responsibility. Use this tool ethically and legally.**
