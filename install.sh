#!/usr/bin/env bash

# Terminal Setup Installation Script
# Supports: Linux (Debian/Ubuntu, Fedora, Arch), macOS, Windows (WSL2 only)
# Requirements: Zsh shell

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

# Cross-platform sed -i (macOS requires different syntax)
sed_inplace() {
    if [[ "$OS" == "macos" ]]; then
        sed -i '' "$@"
    else
        sed -i "$@"
    fi
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
            sudo apt install -y tmux neovim kitty git curl build-essential python3 python3-pip ripgrep fd-find zsh unzip

            # Install Node.js via NodeSource (apt version is often outdated)
            if ! command_exists node; then
                log_info "Installing Node.js..."
                curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
                sudo apt install -y nodejs
            fi

            # Create symlinks for fd (Debian/Ubuntu packages it as fd-find)
            if ! command_exists fd && command_exists fdfind; then
                sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
            fi
            ;;

        fedora|rhel|centos)
            log_info "Using dnf/yum package manager..."
            if command_exists dnf; then
                sudo dnf install -y tmux neovim kitty git curl gcc make python3 python3-pip ripgrep fd-find zsh unzip nodejs npm
            else
                sudo yum install -y tmux neovim kitty git curl gcc make python3 python3-pip ripgrep fd-find zsh unzip nodejs npm
            fi
            ;;

        arch|manjaro|endeavouros)
            log_info "Using pacman package manager..."
            sudo pacman -Syu --noconfirm tmux neovim kitty git curl base-devel python python-pip ripgrep fd zsh unzip nodejs npm
            ;;

        opensuse*)
            log_info "Using zypper package manager..."
            sudo zypper install -y tmux neovim kitty git curl gcc make python3 python3-pip ripgrep fd zsh unzip nodejs npm
            ;;

        macos)
            log_info "Using Homebrew package manager..."
            if ! command_exists brew; then
                log_info "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

                # Setup Homebrew PATH for Apple Silicon or Intel Macs
                if [[ -f "/opt/homebrew/bin/brew" ]]; then
                    # Apple Silicon
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                elif [[ -f "/usr/local/bin/brew" ]]; then
                    # Intel Mac
                    eval "$(/usr/local/bin/brew shellenv)"
                fi
            fi
            brew update
            brew install tmux neovim kitty git curl python ripgrep fd zsh node
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
        log_info "Installing Tmux Plugin Manager (cloning from GitHub)..."
        mkdir -p "$HOME/.tmux/plugins"
        # Use --depth 1 for faster clone, disable prompts with GIT_TERMINAL_PROMPT=0
        if GIT_TERMINAL_PROMPT=0 git clone --depth 1 https://github.com/tmux-plugins/tpm.git "$tpm_path" 2>&1; then
            log_success "TPM installed"
        else
            log_error "Failed to clone TPM. Check your internet connection."
            log_info "You can manually install TPM later with:"
            log_info "  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm"
            return 1
        fi
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
    log_success "Tmux config file copied to $tmux_conf"

    # Install TPM (non-blocking, continues even if it fails)
    install_tpm || true

    log_info "To install tmux plugins: start tmux, then press Ctrl+b followed by Shift+i"
    log_success "Tmux configuration installed"
}

# Install Neovim configuration
install_nvim_config() {
    log_info "Installing Neovim configuration..."

    local nvim_config_dir="$HOME/.config/nvim"

    backup_config "$nvim_config_dir"

    mkdir -p "$nvim_config_dir"
    cp -r "$SCRIPT_DIR/nvim/"* "$nvim_config_dir/"

    log_success "Neovim configuration installed"
    log_info "Run 'nvim' and plugins will be automatically installed via lazy.nvim"
}

# Install Kitty configuration
install_kitty_config() {
    log_info "Installing Kitty configuration..."

    local kitty_config_dir="$HOME/.config/kitty"

    backup_config "$kitty_config_dir"

    mkdir -p "$kitty_config_dir"
    cp "$SCRIPT_DIR/kitty/"* "$kitty_config_dir/"

    log_success "Kitty configuration installed"
}

# Install Oh My Zsh
install_oh_my_zsh() {
    log_info "Installing Oh My Zsh..."

    # Check if zsh is installed
    if ! command_exists zsh; then
        log_warning "Zsh is not installed. Installing zsh first..."
        case "$DISTRO" in
            ubuntu|debian|pop|linuxmint)
                sudo apt install -y zsh
                ;;
            fedora|rhel|centos)
                if command_exists dnf; then
                    sudo dnf install -y zsh
                else
                    sudo yum install -y zsh
                fi
                ;;
            arch|manjaro|endeavouros)
                sudo pacman -S --noconfirm zsh
                ;;
            opensuse*)
                sudo zypper install -y zsh
                ;;
            macos)
                brew install zsh
                ;;
            *)
                log_error "Cannot install zsh automatically on $DISTRO"
                log_info "Please install zsh manually and run this script again"
                return 1
                ;;
        esac
    fi

    log_success "Zsh installed"

    # Check if Oh My Zsh is already installed
    if [ -d "$HOME/.oh-my-zsh" ]; then
        log_info "Oh My Zsh is already installed"

        # Update it
        log_info "Updating Oh My Zsh..."
        if [ -f "$HOME/.oh-my-zsh/tools/upgrade.sh" ]; then
            env ZSH="$HOME/.oh-my-zsh" sh "$HOME/.oh-my-zsh/tools/upgrade.sh" || true
        fi
    else
        # Install Oh My Zsh
        log_info "Downloading and installing Oh My Zsh..."
        RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true
        log_success "Oh My Zsh installed"
    fi

    # Install popular plugins
    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    # zsh-autosuggestions
    if [ ! -d "$zsh_custom/plugins/zsh-autosuggestions" ]; then
        log_info "Installing zsh-autosuggestions..."
        GIT_TERMINAL_PROMPT=0 git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions.git "$zsh_custom/plugins/zsh-autosuggestions" || log_warning "Failed to install zsh-autosuggestions"
    fi

    # zsh-syntax-highlighting
    if [ ! -d "$zsh_custom/plugins/zsh-syntax-highlighting" ]; then
        log_info "Installing zsh-syntax-highlighting..."
        GIT_TERMINAL_PROMPT=0 git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$zsh_custom/plugins/zsh-syntax-highlighting" || log_warning "Failed to install zsh-syntax-highlighting"
    fi

    # zsh-completions
    if [ ! -d "$zsh_custom/plugins/zsh-completions" ]; then
        log_info "Installing zsh-completions..."
        GIT_TERMINAL_PROMPT=0 git clone --depth 1 https://github.com/zsh-users/zsh-completions.git "$zsh_custom/plugins/zsh-completions" || log_warning "Failed to install zsh-completions"
    fi

    # Update .zshrc with recommended plugins and theme
    if [ -f "$HOME/.zshrc" ]; then
        # Backup original .zshrc
        if ! grep -q "# Modified by terminal setup" "$HOME/.zshrc"; then
            cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"

            # Update theme to use a nice one
            if grep -q '^ZSH_THEME=' "$HOME/.zshrc"; then
                sed_inplace 's/^ZSH_THEME=.*/ZSH_THEME="robbyrussell"  # Modified by terminal setup/' "$HOME/.zshrc"
            fi

            # Update plugins
            if grep -q '^plugins=' "$HOME/.zshrc"; then
                sed_inplace 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)  # Modified by terminal setup/' "$HOME/.zshrc"
            fi
        fi
    fi

    # Offer to change default shell to zsh
    if [ "$SHELL" != "$(which zsh)" ]; then
        log_info "Your current shell is: $SHELL"
        log_info "To make zsh your default shell, run: chsh -s \$(which zsh)"
    fi

    log_success "Oh My Zsh setup complete"
}

# Setup shell integrations
setup_shell_integrations() {
    log_info "Setting up zsh integrations..."

    local shell_config="$HOME/.zshrc"

    # Ensure .zshrc exists
    if [ ! -f "$shell_config" ]; then
        log_warning ".zshrc not found. Oh My Zsh should have created it."
        return 1
    fi

    # Add Homebrew PATH setup for macOS (must be before aliases)
    if [[ "$OS" == "macos" ]] && ! grep -q "# Homebrew PATH setup" "$shell_config" 2>/dev/null; then
        # Prepend Homebrew PATH setup to ensure it's loaded early
        local temp_file=$(mktemp)
        cat > "$temp_file" << 'EOF'
# Homebrew PATH setup (added by terminal setup)
if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

EOF
        cat "$shell_config" >> "$temp_file"
        mv "$temp_file" "$shell_config"
        log_success "Homebrew PATH setup added to $shell_config"
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

    for cmd in tmux nvim kitty git node npm; do
        if command_exists "$cmd"; then
            log_success "$cmd is installed ($(command -v $cmd))"
        else
            log_error "$cmd is NOT installed"
            all_good=false
        fi
    done

    # Show versions for key tools
    if command_exists node; then
        log_info "Node.js version: $(node --version)"
    fi
    if command_exists npm; then
        log_info "npm version: $(npm --version)"
    fi

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
    echo "  1) Install all (packages + configs + Oh My Zsh)"
    echo "  2) Install packages only (tmux, nvim, kitty, fonts)"
    echo "  3) Install/update configs only (skip package installation)"
    echo "  4) Install tmux config only"
    echo "  5) Install neovim config only"
    echo "  6) Install kitty config only"
    echo "  7) Install Oh My Zsh only"
    echo "  8) Exit"
    echo ""
    read -p "Enter your choice [1-8]: " choice
    echo ""

    case $choice in
        1) return 1 ;;
        2) return 2 ;;
        3) return 3 ;;
        4) return 4 ;;
        5) return 5 ;;
        6) return 6 ;;
        7) return 7 ;;
        8) return 0 ;;
        *)
            log_error "Invalid choice. Please select 1-8."
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

1. ${YELLOW}Start using Zsh (if Oh My Zsh was installed):${NC}
   exec zsh
   # Or make it your default shell: chsh -s \$(which zsh)

2. ${YELLOW}Reload your shell configuration:${NC}
   source ~/.zshrc

3. ${YELLOW}Start tmux and install plugins:${NC}
   tmux
   # Press: Ctrl+b then Shift+i (to install plugins)

4. ${YELLOW}Open Neovim to install plugins:${NC}
   nvim
   # Plugins will auto-install via lazy.nvim
   # Wait for all plugins to install, then restart nvim

5. ${YELLOW}Start using Kitty terminal:${NC}
   kitty
   # Your new terminal emulator with configs

${BLUE}Troubleshooting:${NC}

- If tmux plugins don't load: Prefix + Shift+i
- If nvim has issues: Run :checkhealth in neovim
- If Mason LSP fails: Ensure node/npm are in PATH (run: node --version)
- If fonts don't work: Restart your terminal
- If zsh plugins don't work: Check ~/.zshrc for correct plugin list
- macOS: If commands not found after install, restart terminal or run: source ~/.zshrc

${GREEN}Enjoy your new terminal setup!${NC}

EOF
}

# Main installation flow
main() {
    log_info "Starting terminal setup installation..."

    # Detect OS
    detect_os

    # Check for unsupported platforms
    if [[ "$OS" == "unknown" ]]; then
        log_error "Unsupported operating system"
        log_info "This script supports Linux and macOS only (Windows users should use WSL2)"
        exit 1
    fi

    # Warn if not running in zsh
    if [ -z "$ZSH_VERSION" ] && command_exists zsh; then
        log_warning "You're not running zsh. This setup is designed for zsh."
        log_info "After installation completes, switch to zsh with: exec zsh"
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

            # Install Oh My Zsh
            install_oh_my_zsh || log_warning "Oh My Zsh installation had issues"

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

        7)
            # Install Oh My Zsh only
            install_oh_my_zsh
            log_success "Oh My Zsh installation complete!"
            log_info "To start using zsh, run: exec zsh"
            exit 0
            ;;
    esac

    # Print final instructions
    print_instructions

    log_success "Installation complete! Enjoy your new terminal setup!"
}

# Run main function
main "$@"
