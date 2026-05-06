#!/data/data/com.termux/files/usr/bin/bash

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
YELLOW="\033[1;33m"
NC="\033[0m"

show_header() {
    clear
    echo -e "${BLUE}==========================================${NC}"
    echo -e "${CYAN}    🌟 OPENCODE MASTER MANAGER V2.0    ${NC}"
    echo -e "${BLUE}==========================================${NC}"
}

install_or_update_local_build() {
    echo -e "${YELLOW}[*] Preparing local Termux builder for OpenCode...${NC}"

    # 1. install Dependencies  (hide log  > /dev/null 2>&1)
    echo -e "${BLUE}[*] Installing required build dependencies (clang, python, make, etc.)...${NC}"
    pkg install -y git make patchelf binutils wget jq clang python curl > /dev/null 2>&1
    
    BUILD_DIR="$HOME/tmp/opencode-termux-build"
    
    # 2. pull Original Repo realtime
    echo -e "${YELLOW}[*] Fetching latest version tag from upstream (anomalyco/opencode)...${NC}"
    UPSTREAM_REPO="anomalyco/opencode"
    LATEST_VER=$(curl -s "https://api.github.com/repos/$UPSTREAM_REPO/releases/latest" | grep '"tag_name":' | cut -d '"' -f 4 | sed 's/v//')
    
    if [ -z "$LATEST_VER" ]; then
        echo -e "${RED}[!] Failed to get upstream version from GitHub API. Please check your internet.${NC}"
        return 1
    fi
    echo -e "${GREEN}[+] Target Upstream Version: v$LATEST_VER${NC}"

    # 3. Prepare Build 
    echo -e "${BLUE}[*] Preparing clean build environment...${NC}"
    if [ -d "$BUILD_DIR" ]; then
        rm -rf "$BUILD_DIR"
    fi
    
    mkdir -p "$HOME/tmp"
    git clone --depth 1 https://github.com/Hope2333/opencode-termux.git "$BUILD_DIR" > /dev/null 2>&1
    
    # Clone bun loader
    git clone --depth 1 https://github.com/Hope2333/bun-termux-loader.git "$BUILD_DIR/third-party/bun-termux-loader" > /dev/null 2>&1
    
    echo -e "${CYAN}[*] Starting local compilation and packaging for version: $LATEST_VER...${NC}"
    echo -e "${YELLOW}[!] This may take a few minutes. Please wait...${NC}"
    
    cd "$BUILD_DIR"
    
    # 4. start to Build
    make all VER="$LATEST_VER" PKG=deb
    
    # 5. search DIR .deb 
    DEB_FILE=$(find "$BUILD_DIR" -type f -name "opencode_${LATEST_VER}_*.deb" | head -n 1)
    
    if [ -n "$DEB_FILE" ] && [ -f "$DEB_FILE" ]; then
        echo -e "${BLUE}[*] Local build successful! Installing package...${NC}"
        pkg install --reinstall -y "$DEB_FILE"
        echo -e "${GREEN}[+] OpenCode successfully updated to Real-Time Latest Version (v$LATEST_VER)!${NC}"
        
        
        rm -rf "$BUILD_DIR"
        echo -e "${BLUE}[*] Cleaned up temporary build files.${NC}"
    else
        echo -e "${RED}[!] Build failed. Could not find generated .deb file.${NC}"
        echo -e "${YELLOW}[!] Please check the compilation logs above for errors.${NC}"
        return 1
    fi
}

install_fresh() {
    show_header
    echo -e "${YELLOW}[*] Preparing fresh installation...${NC}"
    
    # ติดตั้งระบบ Glibc สำหรับ Termux
    echo -e "${BLUE}[*] Setting up Termux glibc environment...${NC}"
    pkg update -y && pkg upgrade -y
    pkg install -y tur-repo
    pkg install -y glibc-repo
    pkg install -y glibc openssl-glibc ripgrep curl
    
    install_or_update_local_build
    echo -e "\n${GREEN}[+] Fresh installation complete! Type 'opencode' to start.${NC}"
    read -p "Press Enter to return to menu..."
}

update_only() {
    show_header
    echo -e "${YELLOW}[*] Checking for updates...${NC}"
    
    if ! command -v opencode >/dev/null 2>&1; then
        echo -e "${RED}[!] Opencode is not installed. Please use Option 1 for Fresh Installation first.${NC}"
        read -p "Press Enter to return to menu..."
        return
    fi
    
    install_or_update_local_build
    read -p "Press Enter to return to menu..."
}

add_multi_agent() {
    show_header
    echo -e "${BLUE}[*] Registering Multi-Agent System...${NC}"
    if [ -f "/sdcard/Download/AGENT1.md" ]; then
        cp "/sdcard/Download/AGENT1.md" "$HOME/AGENTS.md"
        echo -e "${GREEN}[+] AGENTS.md linked to Home directory.${NC}"
    else
        echo -e "${RED}[!] Error: /sdcard/Download/AGENT1.md not found!${NC}"
    fi
    read -p "Press Enter to return to menu..."
}

while true; do
    show_header
    VER=$(opencode --version 2>/dev/null || echo "NOT INSTALLED")
    echo -e "Current Opencode: ${YELLOW}$VER${NC}"
    echo -e "${BLUE}------------------------------------------${NC}"
    echo -e "1) ${GREEN}Full Fresh Installation${NC}"
    echo -e "2) ${GREEN}Quick Update to Latest${NC}"
    echo -e "3) ${GREEN}Install Multi-Agent Skill (AGENT1.md)${NC}"
    echo -e "4) ${RED}Exit${NC}"
    echo -e "${BLUE}------------------------------------------${NC}"
    echo -n "Select: "
    read opt
    case $opt in
        1) install_fresh ;;
        2) update_only ;;
        3) add_multi_agent ;;
        4) exit 0 ;;
        *) echo -e "Invalid option"; sleep 1 ;;
    esac
done
