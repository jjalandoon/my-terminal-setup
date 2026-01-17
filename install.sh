#!/usr/bin/env bash

# Terminal Setup Installation Script
# Supports: Linux (Debian/Ubuntu, Fedora, Arch), macOS, Windows (WSL/Git Bash)

set -e

# Colors for output (always enabled for modern terminals)
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
NC=$'\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect OS and Distribution
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            OS="linux"
            DISTRO=$ID
        else
            OS="linux"
            DISTRO="unknown"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        DISTRO="macos"
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
        OS="windows"
        DISTRO="windows"
    else
        OS="unknown"
        DISTRO="unknown"
    fi

    log_info "Detected OS: $OS, Distribution: $DISTRO"
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Backup existing configuration
backup_config() {
    local config_path="$1"
    local config_name="$(basename "$config_path")"

    if [ -e "$config_path" ]; then
        local backup_path="${config_path}.backup.$(date +%Y%m%d_%H%M%S)"
        log_warning "Backing up existing $config_name to $backup_path"
        mv "$config_path" "$backup_path"
        return 0
    fi
    return 1
}

# Install packages based on OS
install_packages() {
    log_info "Installing required packages..."

    case "$DISTRO" in
        ubuntu|debian|pop|linuxmint)
            log_info "Using apt package manager..."
            sudo apt update
            sudo apt install -y tmux neovim kitty git curl build-essential python3 python3-pip ripgrep fd-find

            # Create symlinks for fd (Debian/Ubuntu packages it as fd-find)
            if ! command_exists fd && command_exists fdfind; then
                sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
            fi
            ;;

        fedora|rhel|centos)
            log_info "Using dnf/yum package manager..."
            if command_exists dnf; then
                sudo dnf install -y tmux neovim kitty git curl gcc make python3 python3-pip ripgrep fd-find
            else
                sudo yum install -y tmux neovim kitty git curl gcc make python3 python3-pip ripgrep fd-find
            fi
            ;;

        arch|manjaro|endeavouros)
            log_info "Using pacman package manager..."
            sudo pacman -Syu --noconfirm tmux neovim kitty git curl base-devel python python-pip ripgrep fd
            ;;

        opensuse*)
            log_info "Using zypper package manager..."
            sudo zypper install -y tmux neovim kitty git curl gcc make python3 python3-pip ripgrep fd
            ;;

        macos)
            log_info "Using Homebrew package manager..."
            if ! command_exists brew; then
                log_info "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            brew update
            brew install tmux neovim kitty git curl python ripgrep fd
            ;;

        windows)
            log_warning "Windows detected. Please ensure you're using WSL for best experience."
            log_info "Installing via Scoop (if available) or use WSL..."
            if command_exists scoop; then
                scoop install tmux neovim kitty git curl
            else
                log_warning "Please install packages manually or use WSL"
                log_info "Recommend using WSL2 with Ubuntu for Windows users"
            fi
            ;;

        *)
            log_error "Unsupported distribution: $DISTRO"
            log_info "Please install tmux, neovim, and kitty manually"
            return 1
            ;;
    esac

    log_success "Package installation completed"
}

# Install Nerd Fonts
install_nerd_fonts() {
    log_info "Installing Nerd Fonts..."

    local fonts_dir
    if [[ "$OS" == "macos" ]]; then
        fonts_dir="$HOME/Library/Fonts"
    elif [[ "$OS" == "linux" ]]; then
        fonts_dir="$HOME/.local/share/fonts"
    else
        fonts_dir="$HOME/.fonts"
    fi

    mkdir -p "$fonts_dir"

    # Install Mononoki Nerd Font
    if [ ! -f "$fonts_dir/MononokiNerdFont-Regular.ttf" ]; then
        log_info "Downloading Mononoki Nerd Font..."
        local temp_dir=$(mktemp -d)
        cd "$temp_dir"
        curl -fLo "Mononoki.zip" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Mononoki.zip
        unzip -o Mononoki.zip -d "$fonts_dir"
        cd - > /dev/null
        rm -rf "$temp_dir"

        # Refresh font cache on Linux
        if [[ "$OS" == "linux" ]]; then
            fc-cache -fv
        fi

        log_success "Mononoki Nerd Font installed"
    else
        log_info "Mononoki Nerd Font already installed"
    fi
}

# Install Tmux Plugin Manager
install_tpm() {
    local tpm_path="$HOME/.tmux/plugins/tpm"

    if [ ! -d "$tpm_path" ]; then
        log_info "Installing Tmux Plugin Manager..."
        git clone https://github.com/tmux-plugins/tpm "$tpm_path"
        log_success "TPM installed"
    else
        log_info "TPM already installed"
    fi
}

# Install Tmux configuration
install_tmux_config() {
    log_info "Installing Tmux configuration..."

    local tmux_conf="$HOME/.tmux.conf"
    backup_config "$tmux_conf"

    cp "$SCRIPT_DIR/tmux.conf" "$tmux_conf"

    # Install TPM
    install_tpm

    # Install TPM plugins
    if [ -f "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]; then
        log_info "Installing Tmux plugins..."
        "$HOME/.tmux/plugins/tpm/bin/install_plugins"
    fi

    log_success "Tmux configuration installed"
}

# Install Neovim configuration
install_nvim_config() {
    log_info "Installing Neovim configuration..."

    local nvim_config_dir
    if [[ "$OS" == "windows" ]]; then
        nvim_config_dir="$HOME/AppData/Local/nvim"
    else
        nvim_config_dir="$HOME/.config/nvim"
    fi

    backup_config "$nvim_config_dir"

    mkdir -p "$nvim_config_dir"
    cp -r "$SCRIPT_DIR/nvim/"* "$nvim_config_dir/"

    log_success "Neovim configuration installed"
    log_info "Run 'nvim' and plugins will be automatically installed via lazy.nvim"
}

# Install Kitty configuration
install_kitty_config() {
    log_info "Installing Kitty configuration..."

    local kitty_config_dir
    if [[ "$OS" == "macos" ]]; then
        kitty_config_dir="$HOME/.config/kitty"
    elif [[ "$OS" == "linux" ]]; then
        kitty_config_dir="$HOME/.config/kitty"
    elif [[ "$OS" == "windows" ]]; then
        kitty_config_dir="$HOME/AppData/Roaming/kitty"
    fi

    backup_config "$kitty_config_dir"

    mkdir -p "$kitty_config_dir"
    cp "$SCRIPT_DIR/kitty/"* "$kitty_config_dir/"

    log_success "Kitty configuration installed"
}

# Setup shell integrations
setup_shell_integrations() {
    log_info "Setting up shell integrations..."

    local shell_config
    if [ -n "$BASH_VERSION" ]; then
        shell_config="$HOME/.bashrc"
    elif [ -n "$ZSH_VERSION" ]; then
        shell_config="$HOME/.zshrc"
    else
        log_warning "Unknown shell, skipping shell integration"
        return
    fi

    # Add helpful aliases if not already present
    if ! grep -q "# Terminal setup aliases" "$shell_config" 2>/dev/null; then
        cat >> "$shell_config" << 'EOF'

# Terminal setup aliases
alias vim='nvim'
alias vi='nvim'
alias tmux='tmux -2'  # Force 256 color support

# fzf integration (if available)
if command -v fzf &> /dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi
EOF
        log_success "Shell integrations added to $shell_config"
    else
        log_info "Shell integrations already present"
    fi
}

# Verify installations
verify_installations() {
    log_info "Verifying installations..."

    local all_good=true

    for cmd in tmux nvim kitty git; do
        if command_exists "$cmd"; then
            log_success "$cmd is installed"
        else
            log_error "$cmd is NOT installed"
            all_good=false
        fi
    done

    if [ "$all_good" = true ]; then
        log_success "All required tools are installed!"
    else
        log_error "Some tools are missing. Please install them manually."
        return 1
    fi
}

# Show installation menu
show_menu() {
    echo ""
    log_info "Terminal Setup Installation"
    echo ""
    echo "What would you like to do?"
    echo ""
    echo "  1) Install all (packages + configs)"
    echo "  2) Install packages only (tmux, nvim, kitty, fonts)"
    echo "  3) Install/update configs only (skip package installation)"
    echo "  4) Install tmux config only"
    echo "  5) Install neovim config only"
    echo "  6) Install kitty config only"
    echo "  7) Exit"
    echo ""
    read -p "Enter your choice [1-7]: " choice
    echo ""

    case $choice in
        1) return 1 ;;
        2) return 2 ;;
        3) return 3 ;;
        4) return 4 ;;
        5) return 5 ;;
        6) return 6 ;;
        7) return 0 ;;
        *)
            log_error "Invalid choice. Please select 1-7."
            show_menu
            return $?
            ;;
    esac
}

# Print post-installation instructions
print_instructions() {
    cat << EOF

${GREEN}======================================${NC}
${GREEN}Installation Complete!${NC}
${GREEN}======================================${NC}

${BLUE}Next Steps:${NC}

1. ${YELLOW}Reload your shell configuration:${NC}
   source ~/.bashrc  # or source ~/.zshrc

2. ${YELLOW}Start tmux and install plugins:${NC}
   tmux
   # Press: Ctrl+b then Shift+i (to install plugins)

3. ${YELLOW}Open Neovim to install plugins:${NC}
   nvim
   # Plugins will auto-install via lazy.nvim
   # Wait for all plugins to install, then restart nvim

4. ${YELLOW}Start using Kitty terminal:${NC}
   kitty
   # Your new terminal emulator with configs

- If nvim has issues: Run :checkhealth in neovim
- If fonts don't work: Restart your terminal

${GREEN}Enjoy your new terminal setup!${NC}

EOF
}

# Main installation flow
main() {
    log_info "Starting terminal setup installation..."

    # Detect OS
    detect_os

    # Check if running with appropriate permissions
    if [[ "$OS" == "windows" ]] && ! command_exists git; then
        log_error "Please run this script from Git Bash or WSL"
        exit 1
    fi

    # Show menu and get user choice
    set +e  # Temporarily disable exit on error
    show_menu
    menu_choice=$?
    set -e  # Re-enable exit on error

    if [ $menu_choice -eq 0 ]; then
        log_info "Installation cancelled"
        exit 0
    fi

    case $menu_choice in
        1)
            # Install all
            log_info "Installing all packages and configurations..."

            # Install packages
            install_packages || true

            # Verify installations
            verify_installations || log_warning "Some tools may need manual installation"

            # Install fonts
            install_nerd_fonts || log_warning "Font installation failed, install manually"

            # Install configurations
            install_tmux_config
            install_nvim_config

            # Only install kitty config if kitty is available
            if command_exists kitty; then
                install_kitty_config
            else
                log_warning "Kitty not installed, skipping config installation"
            fi

            # Setup shell integrations
            setup_shell_integrations
            ;;

        2)
            # Install packages only
            log_info "Installing packages only..."

            # Install packages
            install_packages || true

            # Verify installations
            verify_installations || log_warning "Some tools may need manual installation"

            # Install fonts
            install_nerd_fonts || log_warning "Font installation failed, install manually"

            log_success "Packages installed! Run this script again to install configs."
            exit 0
            ;;

        3)
            # Install configs only
            log_info "Installing/updating configurations only..."

            # Check if tools are installed
            local missing_tools=false
            for cmd in tmux nvim; do
                if ! command_exists "$cmd"; then
                    log_warning "$cmd is not installed"
                    missing_tools=true
                fi
            done

            if [ "$missing_tools" = true ]; then
                read -p "Some tools are missing. Continue anyway? (y/N): " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    log_info "Installation cancelled"
                    exit 0
                fi
            fi

            # Install configurations
            if command_exists tmux; then
                install_tmux_config
            fi

            if command_exists nvim; then
                install_nvim_config
            fi

            if command_exists kitty; then
                install_kitty_config
            else
                log_warning "Kitty not installed, skipping config installation"
            fi

            # Setup shell integrations
            setup_shell_integrations
            ;;

        4)
            # Install tmux config only
            if command_exists tmux; then
                install_tmux_config
            else
                log_error "Tmux is not installed. Please install it first."
                exit 1
            fi
            log_success "Tmux configuration installed!"
            exit 0
            ;;

        5)
            # Install nvim config only
            if command_exists nvim; then
                install_nvim_config
            else
                log_error "Neovim is not installed. Please install it first."
                exit 1
            fi
            log_success "Neovim configuration installed!"
            exit 0
            ;;

        6)
            # Install kitty config only
            if command_exists kitty; then
                install_kitty_config
            else
                log_error "Kitty is not installed. Please install it first."
                exit 1
            fi
            log_success "Kitty configuration installed!"
            exit 0
            ;;
    esac

    # Print final instructions
    print_instructions

    log_success "Installation complete! Enjoy your new terminal setup!"
}

# Run main function
main "$@"
