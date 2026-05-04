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
    
    # Required dependencies for building
    pkg install -y git make patchelf binutils wget jq
    
    BUILD_DIR="$HOME/tmp/opencode-termux-build"
    
    # Clone or update the build repository
    if [ ! -d "$BUILD_DIR" ]; then
        echo -e "${BLUE}[*] Cloning opencode-termux build repository...${NC}"
        git clone https://github.com/Hope2333/opencode-termux.git "$BUILD_DIR"
    else
        echo -e "${BLUE}[*] Updating existing build repository...${NC}"
        cd "$BUILD_DIR" && git pull
    fi
    
    # Clone bun loader if missing
    if [ ! -d "$BUILD_DIR/third-party/bun-termux-loader" ]; then
        echo -e "${BLUE}[*] Cloning bun-termux-loader...${NC}"
        git clone https://github.com/Hope2333/bun-termux-loader.git "$BUILD_DIR/third-party/bun-termux-loader"
    fi
    
    echo -e "${YELLOW}[*] Fetching latest version tag from upstream (anomalyco/opencode)...${NC}"
    UPSTREAM_REPO="anomalyco/opencode"
    LATEST_VER=$(curl -s "https://api.github.com/repos/$UPSTREAM_REPO/releases/latest" | grep '"tag_name":' | cut -d '"' -f 4 | sed 's/v//')
    
    if [ -z "$LATEST_VER" ]; then
        echo -e "${RED}[!] Failed to get upstream version. Check internet or API limit.${NC}"
        return 1
    fi
    
    echo -e "${CYAN}[*] Starting local compilation and packaging for version: $LATEST_VER...${NC}"
    echo -e "${YELLOW}[!] This may take a few minutes. Please wait...${NC}"
    
    cd "$BUILD_DIR"
    # Clean previous builds
    make clean > /dev/null 2>&1
    
    # Build the package locally
    make all VER="$LATEST_VER" PKG=deb
    
    DEB_FILE="$BUILD_DIR/packaging/dpkg/opencode_${LATEST_VER}_aarch64.deb"
    
    if [ -f "$DEB_FILE" ]; then
        echo -e "${BLUE}[*] Local build successful! Installing...${NC}"
        pkg install --reinstall -y "$DEB_FILE"
        echo -e "${GREEN}[+] Upstream binary updated successfully to the absolute latest version ($LATEST_VER)!${NC}"
        
        # Cleanup work directory to save space
        make clean > /dev/null 2>&1
    else
        echo -e "${RED}[!] Build failed. Could not find generated .deb file.${NC}"
        return 1
    fi
}

install_fresh() {
    show_header
    echo -e "${YELLOW}[*] Preparing fresh installation...${NC}"
    pkg update && pkg upgrade -y
    pkg install -y glibc-repo
    pkg install -y glibc openssl-glibc ripgrep curl
    
    install_or_update_local_build
    read -p "Press Enter..."
}

update_only() {
    show_header
    echo -e "${YELLOW}[*] Checking for updates...${NC}"
    
    if ! command -v opencode >/dev/null 2>&1; then
        echo -e "${RED}[!] Opencode is not installed. Please use Option 1 for Fresh Installation first.${NC}"
        read -p "Press Enter..."
        return
    fi
    
    install_or_update_local_build
    read -p "Press Enter..."
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
    read -p "Press Enter..."
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
        *) echo -e "Invalid"; sleep 1 ;;
    esac
done
