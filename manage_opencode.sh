#!/data/data/com.termux/files/usr/bin/bash

# ==========================================
# Colors & UI
# ==========================================
RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
YELLOW="\033[1;33m"
NC="\033[0m"

show_header() {
    clear
    echo -e "${BLUE}==========================================${NC}"
    echo -e "${CYAN}    🌟 OPENCODE MASTER MANAGER V3.2    ${NC}"
    echo -e "${BLUE}==========================================${NC}"
}

# ==========================================
# Helper: Safe Git Sync 
# ==========================================
safe_git_clone_or_pull() {
    local repo_url=$1
    local target_dir=$2
    
    if [ ! -d "$target_dir" ]; then
        echo -e "${BLUE}[*] Cloning $(basename "$repo_url") for the first time...${NC}"
        
        rm -rf "$target_dir"
        git clone "$repo_url" "$target_dir"
    else
        echo -e "${BLUE}[*] Fetching and syncing latest updates for $(basename "$repo_url")...${NC}"
        cd "$target_dir" || return 1
        
        git reset --hard HEAD > /dev/null 2>&1
        git pull
    fi
}

# ==========================================
# Core Build & Update Engine
# ==========================================
core_build_process() {
    echo -e "${YELLOW}[*] Preparing local Termux builder for OpenCode...${NC}"
    
    
    pkg install -y git make patchelf binutils wget jq curl
    
    BUILD_DIR="$HOME/tmp/opencode-termux-build"
    mkdir -p "$HOME/tmp" # ตรวจสอบเผื่อไม่มีโฟลเดอร์ tmp
    
    
    safe_git_clone_or_pull "https://github.com/Hope2333/opencode-termux.git" "$BUILD_DIR"
    
    
    LOADER_DIR="$BUILD_DIR/third-party/bun-termux-loader"
    safe_git_clone_or_pull "https://github.com/Hope2333/bun-termux-loader.git" "$LOADER_DIR"
    
    
    echo -e "${YELLOW}[*] Fetching latest version tag from upstream (anomalyco/opencode)...${NC}"
    UPSTREAM_REPO="anomalyco/opencode"
    JSON_DATA=$(curl -s "https://api.github.com/repos/$UPSTREAM_REPO/releases/latest")
    LATEST_VER=$(echo "$JSON_DATA" | jq -r '.tag_name' 2>/dev/null | sed 's/v//')
    
    
    if [ -z "$LATEST_VER" ] || [ "$LATEST_VER" == "null" ] || [[ "$LATEST_VER" == http* ]]; then
        echo -e "${RED}[!] Error: GitHub API returned an invalid version format.${NC}"
        echo -e "${YELLOW}[*] Attempting fallback to parse from plain text...${NC}"
        LATEST_VER=$(curl -s "https://api.github.com/repos/$UPSTREAM_REPO/releases/latest" | grep '"tag_name":' | head -n 1 | cut -d '"' -f 4 | sed 's/v//')
        
        if [ -z "$LATEST_VER" ] || [[ "$LATEST_VER" == http* ]]; then
            echo -e "${RED}[!] Critical: Could not resolve valid version. Aborting.${NC}"
            return 1
        fi
    fi
    
    echo -e "${CYAN}[*] Target compilation version confirmed: $LATEST_VER${NC}"
    echo -e "${YELLOW}[!] Compiling application... This might take 2-5 minutes depending on your device.${NC}"
    
    cd "$BUILD_DIR" || return 1
    
    make clean > /dev/null 2>&1
    rm -rf artifacts/* staged/* packaging/dpkg/work 2>/dev/null
    
    # ==========================================
    #  Runtime Patch  Bun (v1.15.5+)
    # ==========================================
    if [ -f "$LOADER_DIR/build.py" ]; then
        echo -e "${YELLOW}[*] Injecting modern ELF structure bypass into Loader...${NC}"
        sed -i 's/if not check_bun_marker(input_data):/if False:/g' "$LOADER_DIR/build.py"
    fi
    
    
    make all VER="$LATEST_VER" PKG=deb
    
    DEB_FILE="$BUILD_DIR/packaging/dpkg/opencode_${LATEST_VER}_aarch64.deb"
    
   
    if [ -f "$DEB_FILE" ]; then
        echo -e "${BLUE}[*] Local build successful! Deploying package...${NC}"
        pkg install --reinstall -y "$DEB_FILE"
        echo -e "${GREEN}[+] Opencode successfully deployed to version: $LATEST_VER !${NC}"
        
       
        make clean > /dev/null 2>&1
        rm -rf "$BUILD_DIR/.work" 2>/dev/null
    else
        echo -e "${RED}[!] Critical Error: Build compilation failed (Generated package not found).${NC}"
        echo -e "${YELLOW}[?] Tip: OpenCode might have structural updates. Please report to the maintainer.${NC}"
        return 1
    fi
}

# ==========================================
# Fix Pacman Glibc Keyring 
# ==========================================
fix_pacman_keyring() {
    echo -e "${YELLOW}[*] Synchronizing and repairing Pacman Glibc security keyring...${NC}"
   
    pacman-key --init > /dev/null 2>&1
    pacman-key --populate > /dev/null 2>&1
    
    
    local target_key="998DE27318E867EA976BA877389CEED64573DFCA"
    pacman-key --recv-keys "$target_key" > /dev/null 2>&1
    pacman-key --lsign-key "$target_key" > /dev/null 2>&1
    
    
    pacman -Syf --noconfirm > /dev/null 2>&1
}

# ==========================================
# Menu Options
# ==========================================
install_fresh() {
    show_header
    echo -e "${YELLOW}[*] Executing Fresh Installation Protocol...${NC}"
    
    
    pkg update && pkg upgrade -y
    pkg install -y glibc-repo jq curl
    pkg install -y glibc openssl-glibc ripgrep
    
    
    fix_pacman_keyring
    
    core_build_process
    echo ""
    read -p "Press Enter to return to main menu..."
}

update_only() {
    show_header
    echo -e "${YELLOW}[*] Executing Real-time Auto-Update Protocol...${NC}"
    
    if ! command -v opencode >/dev/null 2>&1; then
        echo -e "${RED}[!] Detection Error: Opencode binary not found in system paths.${NC}"
        echo -e "${YELLOW}[*] Please select Option 1 to initialize setup first.${NC}"
        echo ""
        read -p "Press Enter to return to main menu..."
        return
    fi
    
    core_build_process
    echo ""
    read -p "Press Enter to return to main menu..."
}

# ==========================================
# Main Loop (Dashboard)
# ==========================================
while true; do
    show_header
    VER=$(opencode --version 2>/dev/null || echo "NOT INSTALLED")
    echo -e "Current Installed Version: ${YELLOW}$VER${NC}"
    echo -e "${BLUE}------------------------------------------${NC}"
    echo -e "1) ${GREEN}Full Fresh Installation (For New Users / System Fix)${NC}"
    echo -e "2) ${GREEN}Real-time Auto Update (Sync directly to Upstream)${NC}"
    echo -e "3) ${RED}Exit Manager${NC}"
    echo -e "${BLUE}------------------------------------------${NC}"
    echo -n "Select operation [1-3]: "
    read opt
    case $opt in
        1) install_fresh ;;
        2) update_only ;;
        3) echo -e "${CYAN}Shutting down manager. Goodbye!${NC}"; exit 0 ;;
        *) echo -e "${RED}Error: Invalid selection.${NC}"; sleep 1 ;;
    esac
done
