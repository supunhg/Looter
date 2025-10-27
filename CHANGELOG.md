# Changelog

## Version 2.0 - Advanced Security Edition (October 28, 2025)

### 🎉 Major Release - Enterprise-Grade Security Auditing Tool

This release transforms Looter into an advanced security auditing tool with proprietary detection algorithms and comprehensive automated analysis capabilities.

### ✨ New Features

#### Cloud Instance Detection & Exploitation
- **AWS EC2 detection** with automatic IAM credential extraction
- **Azure instance detection** with metadata API exploitation
- **Google Cloud Platform detection** with service account token harvesting
- Automatic cloud metadata service querying

#### Advanced Privilege Escalation Detection
- **PolicyKit (Polkit) vulnerability detection** including CVE-2021-4034 (PwnKit)
- **D-Bus misconfiguration analysis**
- **NFS exports analysis** with no_root_squash detection
- **Writable systemd service file detection**
- **Screen/tmux socket hijacking detection**
- **LD_PRELOAD and LD_LIBRARY_PATH hijacking vectors**
- **Interesting group membership analysis** (docker, lxd, disk, shadow, sudo, video)
- **Extended Linux capabilities scanning** with dangerous capability flagging

#### Docker Container Security
- **Docker escape technique detection**
- **Privileged container detection**
- **Docker socket mounting detection**
- **CAP_SYS_ADMIN capability checks**
- **Host filesystem mount detection**

#### Credential & Secret Hunting
- **Bash history password extraction** with pattern matching
- **SSH private key discovery** (all types: RSA, DSA, ECDSA, ED25519)
- **AWS credentials file detection**
- **Hardcoded password search** in scripts (shell, Python, etc.)
- **.env file discovery** in common application directories
- **API key and secret token detection**
- **Certificate and key file enumeration** (.pem, .key, .p12, .pfx)
- **Database credential file detection**

#### Environment & Library Analysis
- **PATH variable exploitation analysis** with writable directory detection
- **LD_PRELOAD hijacking detection**
- **LD_LIBRARY_PATH vulnerability checks**
- **/etc/ld.so.preload manipulation detection**
- **Writable library path detection**
- **Sensitive environment variable detection** (PASSWORD, API_KEY, TOKEN, etc.)

#### Compiler & Development Tools
- **GCC/G++ detection** for exploit compilation capability
- **Python/Perl/Ruby detection** for script-based exploits
- **wget/curl detection** for file download capability
- **netcat/socat detection** for reverse shell capability
- **Development tool enumeration**

#### Advanced File System Analysis
- **Writable paths in common locations** (/opt, /usr/local, /var/www)
- **Interesting /etc file permissions** with critical file flagging
- **Configuration and backup file discovery** (.conf, .bak, .backup)
- **Extended SUID/SGID analysis** with dangerous binary classification

#### Advanced Password File Analysis
- **Detailed /etc/passwd parsing** for shell access users
- **UID 0 user detection** (non-root)
- **Users without passwords** detection
- **Default credential detection** (admin, administrator, guest, etc.)

#### Advanced Color Coding System
- **99% PE Vector** - Critical privilege escalation (bright red boxes)
- **95% PE Vector** - High probability (red text)
- **75% PE Vector** - Medium-high probability (yellow text)
- **Interesting findings** - Investigation recommended (cyan text)

### 🔧 Improvements

#### Configuration
- Added **20+ new scan modules** for granular control
- Added **7 new privilege escalation check toggles**
- Total of **40+ configurable scan options**
- New file search depth configuration
- Enhanced network scanning options

#### Vulnerability Scoring
- Enhanced scoring algorithm with more detection categories
- Automated risk level calculation (CRITICAL → LOW)
- Improved severity classification
- Prioritized recommendation generation

#### Output & Reporting
- Color-coded severity levels (LinPEAS-inspired)
- Better categorization of findings
- Highlighted critical findings with box formatting
- Improved readability with section separators
- Comprehensive scan configuration summary

### 📊 Statistics

- **40+ scan modules** (up from 20)
- **100+ security checks** performed
- **50+ CVE and exploit detections**
- **10+ cloud service detections**
- **20+ credential hunting patterns**

### 🔐 Security Checks Added

#### New Critical Vulnerabilities Detected
- AWS IAM credentials accessible via metadata
- Docker socket mounted in container
- Privileged Docker container running
- Member of docker/lxd/disk group
- Writable systemd service files
- /etc/ld.so.preload writable
- Writable directory in PATH
- Writable library directories

#### New High Vulnerabilities Detected
- Readable SSH private keys
- Passwords in bash history
- AWS credentials file present
- Member of shadow/sudo/admin group
- NFS no_root_squash configuration
- Hijackable screen/tmux sockets
- PolicyKit SUID binary (PwnKit vulnerability)
- Writable D-Bus configuration
- Dangerous capabilities (cap_setuid, cap_sys_admin)

#### New Medium Vulnerabilities Detected
- Compilers available on system
- Development tools present
- Member of video group
- Weak NFS export permissions

### 🚀 Performance

- Optimized network scanning with configurable threads
- Improved file search with depth limits
- Efficient pattern matching for credential hunting
- Reduced false positives with better detection logic

### 📝 Documentation

- Complete README rewrite with feature comparison
- Added comparison table: Looter vs LinPEAS
- Comprehensive configuration guide
- Updated usage examples
- Added CHANGELOG for version tracking

### ⚖️ Legal

- Added proprietary license (All Rights Reserved)
- Copyright © 2025 Supun Hewagamage
- Explicit permission required for use
- Added author information and contact details

---

## Version 1.0 - Initial Release

### Features
- Basic system information gathering
- Hardware enumeration
- Network configuration analysis
- SUID/SGID binary detection
- Basic privilege escalation checks
- SSH configuration analysis
- User and authentication enumeration
- Container detection (Docker, Kubernetes)
- Database detection
- Web server detection
- System log analysis
- Cron job enumeration
- Basic vulnerability scoring
