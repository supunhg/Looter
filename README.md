# Looter - Advanced Linux Security Assessment Tool

<div align="center">

```
╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║         ██╗      ██████╗  ██████╗ ████████╗███████╗██████╗                ║
║         ██║     ██╔═══██╗██╔═══██╗╚══██╔══╝██╔════╝██╔══██╗               ║
║         ██║     ██║   ██║██║   ██║   ██║   █████╗  ██████╔╝               ║
║         ██║     ██║   ██║██║   ██║   ██║   ██╔══╝  ██╔══██╗               ║
║         ███████╗╚██████╔╝╚██████╔╝   ██║   ███████╗██║  ██║               ║
║         ╚══════╝ ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝╚═╝  ╚═╝               ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

**Comprehensive Linux Security Assessment & Vulnerability Analysis Tool**

[![License](https://img.shields.io/badge/license-Proprietary-red.svg)]()
[![Platform](https://img.shields.io/badge/platform-Linux-blue.svg)]()
[![Shell](https://img.shields.io/badge/shell-bash-green.svg)]()

</div>

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Scan Types](#scan-types)
  - [Basic Scan](#1-basic-scan)
  - [Intermediate Scan](#2-intermediate-scan)
  - [Deep Scan - Online](#3-deep-scan---online)
  - [Deep Scan - Offline](#4-deep-scan---offline)
- [Usage Examples](#usage-examples)
- [Requirements](#requirements)
- [Output](#output)
- [Legal Disclaimer](#legal-disclaimer)

---

## 🎯 Overview

**Looter** is a comprehensive security assessment toolkit designed for penetration testers, security researchers, and system administrators. It provides four distinct scanning modes ranging from quick reconnaissance to deep vulnerability analysis with CVE database integration.

### Key Capabilities

- 🔍 **Multi-level scanning** - Choose the right depth for your assessment
- 🌐 **Online CVE integration** - Real-time vulnerability database queries
- 🎯 **Exploit suggestions** - Direct links to ExploitDB and Metasploit modules
- 📊 **Automated risk scoring** - Quantified vulnerability assessment
- 📝 **Detailed reporting** - Comprehensive output with timestamps and evidence

---

## ✨ Features

### Core Features
- ✅ Hardware and software enumeration
- ✅ Network service discovery and port scanning
- ✅ User and permission analysis
- ✅ Privilege escalation vector detection
- ✅ Configuration security assessment
- ✅ CVE database lookups (online mode)
- ✅ Exploit suggestion engine
- ✅ Container escape detection
- ✅ Web application security headers analysis
- ✅ Automated vulnerability scoring

### Advanced Detection
- 🔐 SUID/SGID binary analysis
- 🐳 Docker/container security assessment
- 🌐 Cloud instance detection (AWS/Azure/GCP)
- 🔑 SSH configuration vulnerabilities
- 🗄️ Database exposure detection
- 🔥 Firewall and security feature analysis
- 📦 Outdated software identification
- 🚪 Open port risk assessment

---

## 📦 Installation

### Prerequisites
```bash
# Debian/Ubuntu
sudo apt update
sudo apt install -y nmap netcat curl git exploitdb

# Optional but recommended
sudo apt install -y searchsploit metasploit-framework
```

### Quick Install
```bash
# Download or clone the repository
# Extract to your preferred location
cd Looter

# Make scripts executable
chmod +x *.sh

# Run the main menu
./looter.sh
```

---

## 🚀 Quick Start

### Interactive Menu
```bash
./looter.sh
```

The interactive menu will guide you through selecting the appropriate scan type.

### Direct Script Execution
```bash
# Basic scan
./basic_scan.sh --target 192.168.1.100

# Intermediate scan
./intermediate_scan.sh --target 192.168.1.100 --out report.txt

# Deep scan (online)
./deep_scan_online.sh --target 192.168.1.100

# Deep scan (offline)
./deep_scan_offline.sh
```

---

## 🔎 Scan Types

### 1. **Basic Scan** 
**Speed:** ⚡ Fast (1-5 minutes)  
**Purpose:** Quick reconnaissance and system profiling

#### What's Included:
- ✓ Hardware information (CPU, Memory, Disk)
- ✓ Installed software with version numbers
- ✓ Active and enabled services
- ✓ Open and filtered ports
- ✓ Hostname and IP configuration
- ✓ User accounts and permissions
- ✓ Network connections

#### When to Use:
- Initial reconnaissance
- Quick system profiling
- Live network enumeration
- Time-constrained assessments

#### Usage:
```bash
./basic_scan.sh --target 192.168.1.100 --out basic_report.txt
```

---

### 2. **Intermediate Scan**
**Speed:** ⚡⚡ Moderate (5-15 minutes)  
**Purpose:** Security assessment with vulnerability identification

#### What's Included:
- ✓ Everything from Basic Scan
- ✓ Known vulnerability detection for outdated software
- ✓ Version comparison against secure baselines
- ✓ Security configuration analysis
- ✓ SSH configuration vulnerabilities
- ✓ Firewall status and rules
- ✓ ASLR and security feature checks
- ✓ Available security updates
- ✓ Dangerous service detection
- ✓ Risk scoring and prioritization

#### When to Use:
- Security audits
- Compliance assessments
- Pre-hardening analysis
- Vulnerability management

#### Usage:
```bash
./intermediate_scan.sh --target 192.168.1.100
```

---

### 3. **Deep Scan - Online**
**Speed:** ⚡⚡⚡ Comprehensive (15-45 minutes)  
**Purpose:** Full vulnerability assessment with exploit intelligence  
**Requirements:** ⚠️ **Internet connection required**

#### What's Included:
- ✓ Everything from Intermediate Scan
- ✓ **Real-time CVE database queries** (NIST NVD, CVE-CIRCL)
- ✓ **Exploit database searches** (ExploitDB, Packet Storm)
- ✓ **Metasploit module recommendations**
- ✓ Web application vulnerability scanning
- ✓ HTTP security header analysis
- ✓ Aggressive nmap NSE scripts
- ✓ Version-specific exploit matching
- ✓ Comprehensive risk scoring
- ✓ Detailed remediation guidance

#### CVE Sources:
- NIST National Vulnerability Database
- CVE-CIRCL API
- ExploitDB
- Packet Storm Security
- Metasploit Framework

#### When to Use:
- Penetration testing
- Red team operations
- Vulnerability research
- Exploitation planning
- Security consulting

#### Usage:
```bash
./deep_scan_online.sh --target 192.168.1.100 --out pentest_report.txt
```

#### Example Output:
```
[CRITICAL] Apache vulnerable to path traversal and RCE
  → CVE-2021-41773
  → CVE-2021-42013
  → Exploit: Apache 2.4.49/2.4.50 Path Traversal
  → Metasploit: exploit/multi/http/apache_normalize_path_rce

[HIGH] Kernel vulnerable to Dirty COW (CVE-2016-5195)
  → Exploit available: DirtyCOW Local Privilege Escalation
  → GitHub: https://github.com/dirtycow/dirtycow.github.io
```

---

### 4. **Deep Scan - Offline**
**Speed:** ⚡⚡⚡ Comprehensive (10-30 minutes)  
**Purpose:** Complete local system security audit  
**Requirements:** ❌ No internet required

#### What's Included:
- ✓ Everything from Intermediate Scan (except online CVE queries)
- ✓ **Comprehensive privilege escalation detection**
  - SUID/SGID binary analysis
  - Writable PATH directories
  - Sudo misconfigurations
  - Capabilities analysis
  - Kernel exploit identification
- ✓ **Advanced file permission analysis**
  - World-writable files in critical locations
  - Readable /etc/shadow
  - Writable /etc files
  - Files without owners
- ✓ **Container escape detection**
  - Privileged container detection
  - Docker socket mounting
  - Host filesystem mounts
  - Capability analysis
- ✓ **Cloud instance detection**
  - AWS metadata service
  - Azure IMDS
  - GCP metadata API
  - IAM credential exposure
- ✓ **Password and credential hunting**
  - Bash history analysis
  - Environment variable scanning
  - SSH key discovery
  - Configuration file passwords
  - AWS credentials
- ✓ **Advanced system analysis**
  - PolicyKit vulnerabilities
  - D-Bus misconfigurations
  - NFS export analysis
  - Writable systemd services
  - Screen/tmux session hijacking
  - LD_PRELOAD hijacking vectors
- ✓ **Database security**
  - MySQL/MariaDB exposure
  - PostgreSQL configuration
  - MongoDB security
  - Redis exposure
- ✓ **Interesting group memberships**
  - docker, lxd, disk, shadow groups
  - Privilege escalation via groups
- ✓ **Network discovery** (optional)
  - Local network scanning
  - ARP cache analysis
  - Active connection monitoring

#### When to Use:
- Offline security audits
- Air-gapped systems
- Post-compromise enumeration
- Local privilege escalation research
- CTF challenges
- Internal red team assessments

#### Usage:
```bash
./deep_scan_offline.sh
```

#### Configuration:
The script has extensive configuration options at the top of the file:
```bash
SCAN_BASIC_SYSTEM=true
SCAN_PRIVILEGE_ESCALATION=true
SCAN_CONTAINERS=true
SCAN_CLOUD_DETECTION=true
SCAN_INTERESTING_FILES=true
# ... and many more
```

---

## 💻 Usage Examples

### Example 1: Basic Local Scan
```bash
./basic_scan.sh
```

### Example 2: Remote Target Assessment
```bash
./intermediate_scan.sh --target 10.10.10.50 --out target_report.txt
```

### Example 3: Full Penetration Test with CVE Lookup
```bash
./deep_scan_online.sh --target victim.example.com --out pentest_full.txt
```

### Example 4: CTF Machine Enumeration
```bash
./deep_scan_offline.sh
# Check output file for privilege escalation vectors
```

### Example 5: Using with Output Redirection
```bash
./basic_scan.sh --target 192.168.1.0/24 2>&1 | tee network_scan.log
```

---

## 📋 Requirements

### Required Packages
- bash 4.0+
- coreutils
- procps
- net-tools or iproute2

### Recommended Tools
- `nmap` - Advanced port scanning and service detection
- `netcat` - Network connection testing
- `curl` - Web requests and CVE API queries
- `searchsploit` - Exploit database searches (from exploitdb)
- `metasploit-framework` - Exploit module recommendations

### Installation Commands
```bash
# Debian/Ubuntu
sudo apt install -y nmap netcat-openbsd curl exploitdb

# Red Hat/CentOS
sudo yum install -y nmap nmap-ncat curl

# Arch Linux
sudo pacman -S nmap openbsd-netcat curl exploitdb
```

---

## 📊 Output

### Report Structure
All scans generate timestamped reports with the following structure:

```
═══════════════════════════════════════════════════════════════
LOOTER - [SCAN TYPE]
═══════════════════════════════════════════════════════════════
Scan started: 2025-10-29 23:15:42
Target: 192.168.1.100
User: pentester
═══════════════════════════════════════════════════════════════

╔════════════════════════════════════════════════════════════╗
║  SECTION NAME                                              ║
╚════════════════════════════════════════════════════════════╝

[*] Information messages
[✓] Success messages
[!] Warning messages
[✗] Error messages

[CRITICAL] Critical vulnerabilities
[HIGH] High-severity issues
[MEDIUM] Medium-severity issues
[LOW] Low-severity issues

╔════════════════════════════════════════════════════════════╗
║            VULNERABILITY ASSESSMENT RESULTS                ║
╚════════════════════════════════════════════════════════════╝

Critical: X
High: Y
Medium: Z
Low: W

RISK LEVEL: [CRITICAL/HIGH/ELEVATED/MODERATE/LOW]
```

### Output Files
- **Basic Scan:** `basic_scan_YYYYMMDD_HHMMSS.txt`
- **Intermediate Scan:** `intermediate_scan_YYYYMMDD_HHMMSS.txt`
- **Deep Scan (Online):** `deep_scan_online_YYYYMMDD_HHMMSS.txt`
- **Deep Scan (Offline):** `system_scan_YYYY-MM-DD_HH-MM-SS.txt`

---

## 🎯 Comparison Table

| Feature | Basic | Intermediate | Deep (Online) | Deep (Offline) |
|---------|-------|--------------|---------------|----------------|
| **Time** | 1-5 min | 5-15 min | 15-45 min | 10-30 min |
| **Internet Required** | ❌ | ❌ | ✅ | ❌ |
| Hardware Info | ✅ | ✅ | ✅ | ✅ |
| Software Versions | ✅ | ✅ | ✅ | ✅ |
| Port Scanning | ✅ | ✅ | ✅ | ✅ |
| Service Detection | ✅ | ✅ | ✅ | ✅ |
| Vulnerability Detection | ❌ | ✅ | ✅ | ✅ |
| CVE Lookups | ❌ | ❌ | ✅ | ❌ |
| Exploit Suggestions | ❌ | ❌ | ✅ | ❌ |
| Privilege Escalation | ❌ | Basic | Advanced | Advanced |
| Container Detection | ❌ | ❌ | ✅ | ✅ |
| Cloud Detection | ❌ | ❌ | ✅ | ✅ |
| Credential Hunting | ❌ | ❌ | ❌ | ✅ |
| Risk Scoring | ❌ | ✅ | ✅ | ✅ |

---

## 🔒 Legal Disclaimer

**⚠️ IMPORTANT: READ BEFORE USE ⚠️**

This tool is designed for **authorized security testing only**. Unauthorized access to computer systems is illegal.

### Acceptable Use
- ✅ Testing systems you own
- ✅ Authorized penetration testing with written permission
- ✅ Educational purposes in controlled lab environments
- ✅ Security research on your own infrastructure
- ✅ CTF competitions and training platforms

### Prohibited Use
- ❌ Scanning or testing systems without explicit authorization
- ❌ Using findings for malicious purposes
- ❌ Distributing reports containing sensitive data
- ❌ Violation of applicable laws and regulations

**The authors and contributors are not responsible for misuse of this tool.**

---

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

---

## 📝 License

**Proprietary Software** - See [LICENSE](LICENSE) file for details.

All rights reserved.

---

## 🎓 Educational Resources

### Learning Path
1. Start with **Basic Scan** to understand system enumeration
2. Progress to **Intermediate Scan** to learn vulnerability identification
3. Use **Deep Scan (Online)** to understand CVE mapping and exploitation
4. Master **Deep Scan (Offline)** for post-compromise enumeration

### Related Tools
- LinPEAS - Linux Privilege Escalation Awesome Script
- LinEnum - Linux Enumeration Script
- Linux Smart Enumeration (LSE)
- LinuxPrivChecker

---

## 📈 Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and updates.

---

## ⭐ Star History

If you find this tool useful, please consider starring the repository!

---

<div align="center">

**Made with ❤️ for the security community**

</div>
