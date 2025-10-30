#!/usr/bin/env bash
# Looter - Main Menu
# Select and run different scan types
# Usage: bash ./looter.sh

set -eo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Display main header
clear
cat << "EOF"
╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║         ██╗      ██████╗  ██████╗ ████████╗███████╗██████╗                ║
║         ██║     ██╔═══██╗██╔═══██╗╚══██╔══╝██╔════╝██╔══██╗               ║
║         ██║     ██║   ██║██║   ██║   ██║   █████╗  ██████╔╝               ║
║         ██║     ██║   ██║██║   ██║   ██║   ██╔══╝  ██╔══██╗               ║
║         ███████╗╚██████╔╝╚██████╔╝   ██║   ███████╗██║  ██║               ║
║         ╚══════╝ ╚═════╝  ╚═════╝    ╚═╝   ╚══════╝╚═╝  ╚═╝               ║
║                                                                           ║
║              Advanced Linux Security Assessment Tool                     ║
║                                                                           ║
║                         Main Menu - Select Scan Type                     ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝

EOF

echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}                    SCAN TYPE SELECTION${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}[1]${NC} Basic Scan ${CYAN}(Fast)${NC}"
echo "    → Hardware Info"
echo "    → Installed Software with Versions"
echo "    → Available Services"
echo "    → Open/Filtered Ports"
echo "    → Hostname & IP"
echo "    → Users"
echo ""
echo -e "${YELLOW}[2]${NC} Intermediate Scan ${CYAN}(Moderate)${NC}"
echo "    → All Basic Scan features"
echo "    → Known vulnerabilities of outdated software"
echo "    → Security configuration checks"
echo "    → Package update analysis"
echo ""
echo -e "${YELLOW}[3]${NC} Deep Scan - Online ${CYAN}(Comprehensive)${NC}"
echo "    → All Intermediate Scan features"
echo "    → CVE database lookups ${RED}(requires internet)${NC}"
echo "    → Exploit suggestions from databases"
echo "    → Metasploit module recommendations"
echo "    → Advanced vulnerability scoring"
echo ""
echo -e "${YELLOW}[4]${NC} Deep Scan - Offline ${CYAN}(Comprehensive)${NC}"
echo "    → All scans except online CVE lookups"
echo "    → Comprehensive privilege escalation checks"
echo "    → Container escape detection"
echo "    → Advanced file permission analysis"
echo "    → Local vulnerability assessment"
echo ""
echo -e "${YELLOW}[5]${NC} Custom Scan"
echo "    → Select specific scan modules"
echo ""
echo -e "${YELLOW}[0]${NC} Exit"
echo ""
echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Get user input
read -p "$(echo -e ${GREEN}Select scan type [0-5]: ${NC})" choice

case $choice in
    1)
        echo ""
        echo -e "${GREEN}Starting Basic Scan...${NC}"
        sleep 1
        
        read -p "Enter target (default: 127.0.0.1): " target
        target=${target:-127.0.0.1}
        
        read -p "Enter output file (default: auto): " outfile
        
        if [ -z "$outfile" ]; then
            bash ./basic_scan.sh --target "$target"
        else
            bash ./basic_scan.sh --target "$target" --out "$outfile"
        fi
        ;;
        
    2)
        echo ""
        echo -e "${GREEN}Starting Intermediate Scan...${NC}"
        sleep 1
        
        read -p "Enter target (default: 127.0.0.1): " target
        target=${target:-127.0.0.1}
        
        read -p "Enter output file (default: auto): " outfile
        
        if [ -z "$outfile" ]; then
            bash ./intermediate_scan.sh --target "$target"
        else
            bash ./intermediate_scan.sh --target "$target" --out "$outfile"
        fi
        ;;
        
    3)
        echo ""
        echo -e "${GREEN}Starting Deep Scan (Online)...${NC}"
        echo -e "${YELLOW}Note: This scan requires internet connection for CVE lookups${NC}"
        sleep 2
        
        read -p "Enter target (default: 127.0.0.1): " target
        target=${target:-127.0.0.1}
        
        read -p "Enter output file (default: auto): " outfile
        
        # Check internet connectivity
        if ping -c 1 8.8.8.8 &>/dev/null; then
            echo -e "${GREEN}✓ Internet connection detected${NC}"
        else
            echo -e "${RED}✗ No internet connection detected${NC}"
            echo -e "${YELLOW}CVE lookups will be limited. Continue anyway? (y/n)${NC}"
            read -p "> " continue
            if [ "$continue" != "y" ] && [ "$continue" != "Y" ]; then
                echo "Scan cancelled."
                exit 0
            fi
        fi
        
        if [ -z "$outfile" ]; then
            bash ./deep_scan_online.sh --target "$target"
        else
            bash ./deep_scan_online.sh --target "$target" --out "$outfile"
        fi
        ;;
        
    4)
        echo ""
        echo -e "${GREEN}Starting Deep Scan (Offline)...${NC}"
        echo -e "${YELLOW}Note: This is a comprehensive local scan${NC}"
        sleep 2
        
        bash ./deep_scan_offline.sh
        ;;
        
    5)
        echo ""
        echo -e "${YELLOW}Custom Scan - Feature coming soon!${NC}"
        echo "This will allow you to select specific scan modules."
        sleep 2
        ;;
        
    0)
        echo ""
        echo -e "${CYAN}Exiting Looter...${NC}"
        exit 0
        ;;
        
    *)
        echo ""
        echo -e "${RED}Invalid selection!${NC}"
        echo "Please run the script again and choose a valid option (0-5)"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}                     SCAN COMPLETE${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}Run ./looter.sh again to perform another scan${NC}"
echo ""

exit 0
