# Looter - Quick Reference Guide

## 🚀 Quick Start

```bash
# Interactive menu (recommended)
./looter.sh

# Direct execution
./basic_scan.sh --target 192.168.1.100
./intermediate_scan.sh --target 192.168.1.100
./deep_scan_online.sh --target 192.168.1.100
./deep_scan_offline.sh
```

---

## 📋 Scan Type Cheat Sheet

### 1. Basic Scan - Quick Recon
```bash
./basic_scan.sh [OPTIONS]
```
**Time:** 1-5 minutes | **Internet:** Not Required

**Options:**
- `--target, -t <IP>`    Target host (default: 127.0.0.1)
- `--out, -o <FILE>`     Output file (default: auto)
- `-h, --help`           Show help

**What it does:**
- ✓ Hardware info (CPU, RAM, Disk)
- ✓ Software versions
- ✓ Active services
- ✓ Open ports
- ✓ Network config
- ✓ User accounts

**Use when:** Quick recon, time-limited, live network scanning

---

### 2. Intermediate Scan - Security Check
```bash
./intermediate_scan.sh [OPTIONS]
```
**Time:** 5-15 minutes | **Internet:** Not Required

**Options:**
- `--target, -t <IP>`    Target host
- `--out, -o <FILE>`     Output file
- `-h, --help`           Show help

**What it does:**
- ✓ Everything from Basic Scan
- ✓ Known vulnerabilities
- ✓ Outdated software detection
- ✓ Security misconfigurations
- ✓ Risk scoring

**Use when:** Security audits, compliance checks, vulnerability assessment

---

### 3. Deep Scan (Online) - Full Pentest
```bash
./deep_scan_online.sh [OPTIONS]
```
**Time:** 15-45 minutes | **Internet:** ⚠️ REQUIRED

**Options:**
- `--target, -t <IP>`    Target host
- `--out, -o <FILE>`     Output file
- `-h, --help`           Show help

**What it does:**
- ✓ Everything from Intermediate
- ✓ CVE database queries
- ✓ Exploit suggestions
- ✓ Metasploit modules
- ✓ Web app scanning
- ✓ Comprehensive reporting

**Use when:** Penetration testing, red team, security research

---

### 4. Deep Scan (Offline) - Complete Audit
```bash
./deep_scan_offline.sh
```
**Time:** 10-30 minutes | **Internet:** Not Required

**No options** - Scans local system comprehensively

**What it does:**
- ✓ All scans (except online CVE)
- ✓ Privilege escalation vectors
- ✓ Container escape detection
- ✓ Credential hunting
- ✓ File permission analysis
- ✓ Cloud instance detection

**Use when:** Post-compromise, offline audits, CTF challenges

---

## 🎯 Common Use Cases

### Scenario 1: Initial Network Recon
```bash
./basic_scan.sh --target 10.10.10.0/24
```

### Scenario 2: Security Audit
```bash
./intermediate_scan.sh --target webserver.local --out audit_report.txt
```

### Scenario 3: Penetration Test
```bash
./deep_scan_online.sh --target victim.htb --out pentest_full.txt
```

### Scenario 4: Post-Exploitation Enumeration
```bash
# After gaining shell access
./deep_scan_offline.sh
```

### Scenario 5: CTF Machine
```bash
# Quick overview
./basic_scan.sh

# Find privilege escalation vectors
./deep_scan_offline.sh
grep -i "critical\|high" system_scan_*.txt
```

---

## 🔍 Finding Specific Information

### Find SUID Binaries
```bash
./deep_scan_offline.sh
grep -A 10 "SUID binaries" system_scan_*.txt
```

### Check for Kernel Exploits
```bash
./intermediate_scan.sh
grep -i "kernel\|dirty" intermediate_scan_*.txt
```

### Find CVEs for Target
```bash
./deep_scan_online.sh --target 192.168.1.50
grep "CVE-" deep_scan_online_*.txt
```

### Detect Containers
```bash
./deep_scan_offline.sh
grep -i "docker\|container" system_scan_*.txt
```

### Find Credentials
```bash
./deep_scan_offline.sh
grep -A 5 "PASSWORD\|CREDENTIAL" system_scan_*.txt
```

---

## 📊 Understanding Output

### Risk Levels
- **CRITICAL** - Immediate exploitation possible
- **HIGH** - Significant security risk
- **MEDIUM** - Moderate security concern
- **LOW** - Minor security issue

### Vulnerability Markers
```
[CRITICAL] - Red - Immediate action required
[HIGH]     - Red - High priority
[MEDIUM]   - Yellow - Should address
[LOW]      - Cyan - Good to fix
```

### Information Markers
```
[*] - Information
[✓] - Success
[!] - Warning
[✗] - Error
```

---

## 🛠️ Troubleshooting

### "nmap not found"
```bash
sudo apt install nmap
```

### "Permission denied"
```bash
chmod +x *.sh
```

### "No internet connection" (Deep Scan Online)
- Check network: `ping 8.8.8.8`
- Use offline scan instead: `./deep_scan_offline.sh`

### "Command not found: searchsploit"
```bash
sudo apt install exploitdb
```

### Scan takes too long
- Use Basic Scan for quick results
- Reduce network discovery scope
- Edit deep_scan_offline.sh config section

---

## 📁 Output Files

| Scan Type | Default Filename | Format |
|-----------|-----------------|--------|
| Basic | basic_scan_YYYYMMDD_HHMMSS.txt | Text |
| Intermediate | intermediate_scan_YYYYMMDD_HHMMSS.txt | Text |
| Deep (Online) | deep_scan_online_YYYYMMDD_HHMMSS.txt | Text |
| Deep (Offline) | system_scan_YYYY-MM-DD_HH-MM-SS.txt | Text |

---

## ⚡ Performance Tips

### Speed Up Scans
1. Limit port range in scripts
2. Reduce network discovery timeout
3. Skip optional modules
4. Use Basic Scan for quick checks

### Improve Accuracy
1. Install all recommended tools
2. Run with sudo (for deeper access)
3. Increase timeout values
4. Enable all scan modules

---

## 🔐 Security Best Practices

### Before Scanning
1. ✅ Get written authorization
2. ✅ Verify target scope
3. ✅ Check legal implications
4. ✅ Prepare incident response

### During Scanning
1. ✅ Monitor scan impact
2. ✅ Respect rate limits
3. ✅ Document findings
4. ✅ Keep evidence secure

### After Scanning
1. ✅ Secure report files
2. ✅ Report vulnerabilities responsibly
3. ✅ Follow disclosure policies
4. ✅ Delete sensitive data

---

## 🎓 Tips & Tricks

### Combine with Other Tools
```bash
# Use with LinPEAS
./deep_scan_offline.sh && ./linpeas.sh

# Compare results
./basic_scan.sh --out before.txt
# Make changes
./basic_scan.sh --out after.txt
diff before.txt after.txt
```

### Grep Useful Patterns
```bash
# Find all vulnerabilities
grep -E "CRITICAL|HIGH" *scan*.txt

# Find exploits
grep -i "exploit" *scan*.txt

# Find CVEs
grep -oP "CVE-\d{4}-\d+" *scan*.txt | sort -u
```

### Export Results
```bash
# Convert to markdown
cat basic_scan_*.txt | pandoc -o report.md

# Create PDF
enscript -B basic_scan_*.txt -o - | ps2pdf - report.pdf
```

---

## 📞 Getting Help

### Command Help
```bash
./looter.sh --help
./basic_scan.sh --help
./intermediate_scan.sh --help
./deep_scan_online.sh --help
```

### Common Issues
1. **Scan hangs** - Check network connectivity, reduce timeout
2. **Permission errors** - Run with appropriate privileges
3. **Missing tools** - Install required packages
4. **Large output** - Use grep to filter results

---

## 🔗 Related Resources

- **ExploitDB:** https://www.exploit-db.com/
- **NIST NVD:** https://nvd.nist.gov/
- **GTFOBins:** https://gtfobins.github.io/
- **HackTricks:** https://book.hacktricks.xyz/

---

## 📝 Report Template

```
Target: [IP/Hostname]
Scan Type: [Basic/Intermediate/Deep]
Date: [YYYY-MM-DD]
Tester: [Your Name]

=== EXECUTIVE SUMMARY ===
[Brief overview]

=== FINDINGS ===
Critical: [Count]
High: [Count]
Medium: [Count]
Low: [Count]

=== TOP VULNERABILITIES ===
1. [Vulnerability Name]
   - Severity: [CRITICAL/HIGH/MEDIUM/LOW]
   - CVE: [CVE-XXXX-XXXXX]
   - Impact: [Description]
   - Recommendation: [Fix]

=== DETAILED FINDINGS ===
[Paste scan output]

=== CONCLUSION ===
[Summary and recommendations]
```

---

<div align="center">

**Quick Reference v1.0**  
For full documentation see README.md

</div>
