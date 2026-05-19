#!/data/data/com.termux/files/usr/bin/bash

# ==========================================
# Colors
# ==========================================
RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
YELLOW="\033[1;33m"
NC="\033[0m"

# ==========================================
# UI Functions
# ==========================================
show_header() {
    clear
    echo -e "${BLUE}==========================================${NC}"
    echo -e "${CYAN}    🌟 OPENCODE MASTER MANAGER V3.0    ${NC}"
    echo -e "${BLUE}==========================================${NC}"
}

# ==========================================
# Core Build & Update Engine
# ==========================================
core_build_process() {
    echo -e "${YELLOW}[*] Preparing local Termux builder for OpenCode...${NC}"
    
    # 1. Install dependencies
    pkg install -y git make patchelf binutils wget jq
    
    BUILD_DIR="$HOME/tmp/opencode-termux-build"
    
    # 2. Update or clone main build repo
    if [ ! -d "$BUILD_DIR" ]; then
        echo -e "${BLUE}[*] Cloning opencode-termux build repository...${NC}"
        git clone https://github.com/Hope2333/opencode-termux.git "$BUILD_DIR"
    else
        echo -e "${BLUE}[*] Updating existing build repository...${NC}"
        cd "$BUILD_DIR" && git pull
    fi
    
    # 3. Update or clone bun-termux-loader
    LOADER_DIR="$BUILD_DIR/third-party/bun-termux-loader"
    if [ ! -d "$LOADER_DIR" ]; then
        echo -e "${BLUE}[*] Cloning bun-termux-loader...${NC}"
        git clone https://github.com/Hope2333/bun-termux-loader.git "$LOADER_DIR"
    else
        echo -e "${BLUE}[*] Updating bun-termux-loader to latest version...${NC}"
        cd "$LOADER_DIR" && git pull
    fi
    
    # 4. Fetch latest version from upstream
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
    make clean > /dev/null 2>&1
    
    # ==========================================
    # HACK: Bypass Bun marker for version >= 1.15.5
    # ==========================================
    echo -e "${YELLOW}[*] Applying runtime patch to bypass Bun marker...${NC}"
    sed -i 's/if not check_bun_marker(input_data):/if False:/g' "$LOADER_DIR/build.py"
    
    # 5. Build and Package
    make all VER="$LATEST_VER" PKG=deb
    
    DEB_FILE="$BUILD_DIR/packaging/dpkg/opencode_${LATEST_VER}_aarch64.deb"
    
    if [ -f "$DEB_FILE" ]; then
        echo -e "${BLUE}[*] Local build successful! Installing...${NC}"
        pkg install --reinstall -y "$DEB_FILE"
        echo -e "${GREEN}[+] Opencode updated successfully to the latest version ($LATEST_VER)!${NC}"
        
        # Cleanup
        make clean > /dev/null 2>&1
    else
        echo -e "${RED}[!] Build failed. Could not find generated .deb file.${NC}"
        return 1
    fi
}

# ==========================================
# Menu Options
# ==========================================
install_fresh() {
    show_header
    echo -e "${YELLOW}[*] Preparing fresh installation for new user...${NC}"
    pkg update && pkg upgrade -y
    pkg install -y glibc-repo
    pkg install -y glibc openssl-glibc ripgrep curl
    
    core_build_process
    echo ""
    read -p "Press Enter to return to main menu..."
}

update_only() {
    show_header
    echo -e "${YELLOW}[*] Checking for Real-time updates...${NC}"
    
    if ! command -v opencode >/dev/null 2>&1; then
        echo -e "${RED}[!] Opencode is not installed. Please use Option 1 for Fresh Installation first.${NC}"
        echo ""
        read -p "Press Enter to return to main menu..."
        return
    fi
    
    core_build_process
    echo ""
    read -p "Press Enter to return to main menu..."
}

# ==========================================
# Main Loop
# ==========================================
while true; do
    show_header
    VER=$(opencode --version 2>/dev/null || echo "NOT INSTALLED")
    echo -e "Current Opencode: ${YELLOW}$VER${NC}"
    echo -e "${BLUE}------------------------------------------${NC}"
    echo -e "1) ${GREEN}Full Fresh Installation (For New Users)${NC}"
    echo -e "2) ${GREEN}Real-time Auto Update (To Latest Version)${NC}"
    echo -e "3) ${RED}Exit${NC}"
    echo -e "${BLUE}------------------------------------------${NC}"
    echo -n "Select [1-3]: "
    read opt
    case $opt in
        1) install_fresh ;;
        2) update_only ;;
        3) echo -e "${CYAN}Exiting...${NC}"; exit 0 ;;
        *) echo -e "${RED}Invalid option!${NC}"; sleep 1 ;;
    esac
done
