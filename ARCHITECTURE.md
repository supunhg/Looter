# Looter - Scan Architecture Overview

## 📊 Scan Hierarchy

```
                            ┌─────────────────┐
                            │   LOOTER.SH     │
                            │   Main Menu     │
                            └────────┬────────┘
                                     │
                    ┌────────────────┼────────────────┐
                    │                │                │
                    ▼                ▼                ▼
        ┌──────────────────┐  ┌──────────────┐  ┌──────────────────┐
        │  BASIC SCAN      │  │ INTERMEDIATE │  │   DEEP SCANS     │
        │  Quick Recon     │──│    SCAN      │──│  Comprehensive   │
        │  1-5 minutes     │  │  5-15 min    │  │   10-45 min      │
        └──────────────────┘  └──────────────┘  └─────────┬────────┘
                                                            │
                                              ┌─────────────┴─────────────┐
                                              ▼                           ▼
                                    ┌──────────────────┐      ┌──────────────────┐
                                    │   ONLINE MODE    │      │   OFFLINE MODE   │
                                    │  + CVE Lookups   │      │  + All Local     │
                                    │  + Exploits      │      │  + PrivEsc       │
                                    │  15-45 min       │      │  10-30 min       │
                                    └──────────────────┘      └──────────────────┘
```

---

## 🎯 Feature Comparison Matrix

| Feature Category | Basic | Intermediate | Deep (Online) | Deep (Offline) |
|-----------------|-------|--------------|---------------|----------------|
| **ENUMERATION** |
| System Info | ✅ | ✅ | ✅ | ✅ |
| Hardware Details | ✅ | ✅ | ✅ | ✅ |
| Software Versions | ✅ | ✅ | ✅ | ✅ |
| Network Config | ✅ | ✅ | ✅ | ✅ |
| User Accounts | ✅ | ✅ | ✅ | ✅ |
| Services | ✅ | ✅ | ✅ | ✅ |
| **SCANNING** |
| Port Scanning | ✅ | ✅ | ✅ | ✅ |
| Service Detection | ✅ | ✅ | ✅ Advanced | ✅ Advanced |
| Web App Headers | ❌ | ❌ | ✅ | ❌ |
| NSE Scripts | ❌ | ❌ | ✅ | ❌ |
| **VULNERABILITY ASSESSMENT** |
| Version Checks | ❌ | ✅ | ✅ | ✅ |
| Config Analysis | ❌ | ✅ | ✅ | ✅ |
| CVE Lookups | ❌ | ❌ | ✅ | ❌ |
| Risk Scoring | ❌ | ✅ | ✅ Advanced | ✅ |
| **EXPLOITATION** |
| Exploit Suggestions | ❌ | ❌ | ✅ | ❌ |
| Metasploit Modules | ❌ | ❌ | ✅ | ❌ |
| ExploitDB Links | ❌ | ❌ | ✅ | ❌ |
| **PRIVILEGE ESCALATION** |
| SUID/SGID | ❌ | Basic | ✅ | ✅ Advanced |
| Sudo Analysis | ❌ | Basic | ✅ | ✅ |
| Capabilities | ❌ | ❌ | ✅ | ✅ |
| File Permissions | ❌ | Basic | ✅ | ✅ Advanced |
| Kernel Exploits | ❌ | ✅ | ✅ | ✅ |
| **ADVANCED FEATURES** |
| Container Detection | ❌ | ❌ | ✅ | ✅ |
| Cloud Detection | ❌ | ❌ | ✅ | ✅ |
| Credential Hunting | ❌ | ❌ | ✅ | ✅ |
| Bash History | ❌ | ❌ | ✅ | ✅ |
| LD_PRELOAD Check | ❌ | ❌ | ✅ | ✅ |
| PolicyKit/D-Bus | ❌ | ❌ | ✅ | ✅ |
| Database Security | ❌ | ❌ | ✅ | ✅ |
| **OUTPUT** |
| Colored Output | ✅ | ✅ | ✅ | ✅ |
| Timestamped Report | ✅ | ✅ | ✅ | ✅ |
| Vulnerability Count | ❌ | ✅ | ✅ | ✅ |
| CVE List | ❌ | ❌ | ✅ | ❌ |
| Exploit List | ❌ | ❌ | ✅ | ❌ |
| **REQUIREMENTS** |
| Internet Connection | ❌ | ❌ | ✅ Required | ❌ |
| Root/Sudo | Optional | Optional | Optional | Optional |
| nmap | Recommended | Recommended | Required | Recommended |
| searchsploit | ❌ | ❌ | Recommended | ❌ |

---

## 🔄 Workflow Examples

### Workflow 1: Network Penetration Test
```
1. Basic Scan (identify targets)
   └─> 2. Intermediate Scan (find vulnerabilities)
       └─> 3. Deep Scan Online (get exploits)
           └─> 4. Execute exploitation
```

### Workflow 2: Security Audit
```
1. Intermediate Scan (baseline assessment)
   └─> 2. Deep Scan Offline (detailed analysis)
       └─> 3. Remediation
           └─> 4. Re-scan to verify
```

### Workflow 3: CTF Challenge
```
1. Basic Scan (quick overview)
   └─> 2. Deep Scan Offline (find privesc)
       └─> 3. Exploit SUID/capability
```

### Workflow 4: Post-Compromise
```
1. Deep Scan Online (immediate - if internet available)
   └─> 2. Analyze credentials & vulnerabilities
       └─> 3. Deep Scan Offline (backup/additional checks)
           └─> 4. Lateral movement
```

---

## 📈 Performance Characteristics

### Speed vs Depth Trade-off

```
Depth
  ▲
  │                                      ┌─────────────┐
  │                                      │   Deep      │
  │                             ┌────────│  (Offline)  │
  │                             │        └─────────────┘
  │                             │   ┌─────────────┐
  │                    ┌────────┤   │   Deep      │
  │                    │        │   │  (Online)   │
  │                    │        └───└─────────────┘
  │           ┌────────┤
  │           │        │
  │           │ Inter- │
  │  ┌────────│ mediate│
  │  │        └────────┘
  │  │ Basic
  │  └────────┐
  │           │
  └───────────┴──────────────────────────────────────────► Time
           1-5m    5-15m      15-45m      10-30m
```

### Resource Usage

| Scan Type | CPU | Network | Disk I/O | Memory |
|-----------|-----|---------|----------|--------|
| Basic | Low | Medium | Low | Low |
| Intermediate | Low-Med | Medium | Low | Low |
| Deep (Online) | Medium | High | Low | Medium |
| Deep (Offline) | Medium-High | Low | High | Medium |

---

## 🎨 Output Format Examples

### Basic Scan Output
```
╔════════════════════════════════════════════════════════════╗
║  HOSTNAME & IP INFORMATION                                 ║
╚════════════════════════════════════════════════════════════╝
[*] Hostname: webserver01
[*] IP Addresses:
192.168.1.100
10.0.0.50
```

### Intermediate Scan Output
```
╔════════════════════════════════════════════════════════════╗
║  VULNERABILITY DETECTION - OUTDATED SOFTWARE               ║
╚════════════════════════════════════════════════════════════╝
[*] OpenSSH version: 7.4
[HIGH] OpenSSH version is outdated (7.4 < 8.0)
  → Multiple vulnerabilities fixed in newer versions
```

### Deep Scan (Online) Output
```
╔════════════════════════════════════════════════════════════╗
║  VULNERABILITY SCANNING WITH CVE LOOKUP                    ║
╚════════════════════════════════════════════════════════════╝
[*] Analyzing Apache: 2.4.49
[CRITICAL] Apache vulnerable to path traversal and RCE
  → CVE-2021-41773
  → CVE-2021-42013
  → Exploit: Apache 2.4.49/2.4.50 Path Traversal
  → https://www.exploit-db.com/exploits/50383
```

### Deep Scan (Offline) Output
```
╔════════════════════════════════════════════════════════════╗
║  PRIVILEGE ESCALATION VECTORS                              ║
╚════════════════════════════════════════════════════════════╝
[*] Checking for privilege escalation vectors...
[*] SUID binaries found: 127

[CRITICAL] Dangerous SUID binaries found!
/usr/bin/find
/usr/bin/vim.basic
  → Can be used for privilege escalation
```

---

## 🔐 Security Considerations

### Safe Scanning Practices

```
┌─────────────────────────────────────────────────────────┐
│  PRE-SCAN CHECKLIST                                     │
├─────────────────────────────────────────────────────────┤
│  ☑ Written authorization obtained                       │
│  ☑ Scope clearly defined                                │
│  ☑ Contact information for target                       │
│  ☑ Incident response plan ready                         │
│  ☑ Backup plan in case of issues                        │
│  ☑ Logging and documentation prepared                   │
└─────────────────────────────────────────────────────────┘
```

### Risk Levels by Scan Type

```
Risk to Target System:

Basic Scan:        [▓░░░░] Low
Intermediate:      [▓░░░░] Low  
Deep (Online):     [▓▓░░░] Low-Medium (aggressive nmap)
Deep (Offline):    [▓░░░░] Low (read-only operations)
```

---

## 🚀 Quick Decision Tree

```
START: What do you need?
  │
  ├─ Just system info?
  │  └─> Use: Basic Scan
  │
  ├─ Find vulnerabilities?
  │  └─> Use: Intermediate Scan
  │
  ├─ Need exploits + CVEs?
  │  ├─ Have internet?
  │  │  └─ YES: Deep Scan (Online)
  │  │  └─ NO:  Deep Scan (Offline)
  │  │
  │  └─> Use: Deep Scan (Online)
  │
  └─ Post-compromise enum?
     └─> Use: Deep Scan (Offline)
```

---

## 📦 Installation Paths

```
Looter/
├── looter.sh                    # Main menu (START HERE)
├── basic_scan.sh                # Level 1: Quick recon
├── intermediate_scan.sh         # Level 2: Vulnerability detection
├── deep_scan_online.sh          # Level 3a: CVE + Exploits
├── deep_scan_offline.sh         # Level 3b: Comprehensive local
├── README.md                    # Full documentation
├── QUICKREF.md                  # Quick reference guide
├── CHANGELOG.md                 # Version history
└── LICENSE                      # License information
```

---

## 🎓 Learning Path

```
Week 1: Basic Scanning
├─ Day 1-2: Run basic_scan.sh, understand output
├─ Day 3-4: Learn enumeration techniques
└─ Day 5-7: Practice on lab systems

Week 2: Vulnerability Assessment  
├─ Day 1-2: Run intermediate_scan.sh
├─ Day 3-4: Understand vulnerability scoring
└─ Day 5-7: Research CVEs and patches

Week 3: Advanced Techniques
├─ Day 1-3: Deep scan (online) with CVE lookups
├─ Day 4-5: Deep scan (offline) on compromised systems
└─ Day 6-7: Practice exploit selection

Week 4: Real-World Application
├─ Day 1-7: Complete penetration tests
└─ Master report writing and remediation
```

---

## 📊 Success Metrics

### Effective Scanning
- ✅ Choose appropriate scan type for situation
- ✅ Complete scan in reasonable time
- ✅ Identify critical vulnerabilities
- ✅ Generate actionable reports
- ✅ Follow up on findings

### Red Flags (Don't Do This)
- ❌ Scanning without authorization
- ❌ Using only basic scan for pentest
- ❌ Ignoring critical findings
- ❌ Not documenting results
- ❌ Overwhelming target with aggressive scans

---

<div align="center">

**Architecture Overview v1.1**  
Part of the Looter Security Assessment Suite

**Current Versions:**
- Basic Scan: v1.2
- Intermediate Scan: v1.0
- Deep Scan (Online): v1.0 - **NOW WITH** Credential Hunting, Bash History, LD_PRELOAD, PolicyKit/D-Bus
- Deep Scan (Offline): v2.0

[Main Menu](looter.sh) | [Documentation](README.md) | [Quick Reference](QUICKREF.md)

</div>
