# Modern Terminal Setup

A comprehensive terminal configuration for Zsh featuring Neovim, Tmux, Kitty, and Oh My Zsh with a beautiful Catppuccin Mocha theme.

## Features

### Neovim
- **Base**: Kickstart.nvim configuration
- **Theme**: Catppuccin Mocha
- **LSP Support**: TypeScript, Lua, HTML, CSS
- **Enhanced Plugins**:
  - Smooth scrolling (neoscroll.nvim)
  - Toggle terminal (toggleterm.nvim)
  - Git integration (fugitive, gitsigns)
  - Advanced folding (nvim-ufo)
  - Color highlighting (nvim-colorizer)
  - Better commenting (Comment.nvim)
  - Indent guides (indent-blankline)
  - File explorer (nvim-tree)
  - Fuzzy finder (telescope)
  - Auto-completion (blink.cmp)

### Tmux
- **Theme**: Catppuccin
- **Vi Mode**: Enabled for navigation
- **Enhanced Key Bindings**: Vim-like pane navigation
- **Plugins**:
  - TPM (Tmux Plugin Manager)
  - tmux-sensible
  - tmux-yank (clipboard integration)
  - tmux-resurrect (session persistence)
  - tmux-continuum (automatic session restore)
  - tmux-fzf-links

### Kitty
- **Theme**: Catppuccin Mocha
- **Font**: Mononoki Nerd Font
- **Features**:
  - True color support
  - GPU acceleration
  - Unicode support
  - Advanced keyboard shortcuts
  - Tab and window management

### Oh My Zsh
- **Framework**: Oh My Zsh for enhanced Zsh experience
- **Auto-installed Plugins**:
  - zsh-autosuggestions (intelligent command suggestions)
  - zsh-syntax-highlighting (syntax highlighting for commands)
  - zsh-completions (additional completion definitions)
  - git (Git aliases and functions)
- **Theme**: Robbyrussell (default, easily customizable)
- **Features**:
  - 300+ built-in plugins available
  - Easy theme switching
  - Command auto-completion
  - Plugin management

## Supported Platforms

- **Linux**: Ubuntu, Debian, Fedora, Arch, openSUSE
- **macOS**: Via Homebrew
- **Windows**: Via WSL2 only (native Windows not supported)

## Installation

### Quick Install

```bash
git clone <your-repo-url> ~/my-terminal
cd ~/my-terminal
chmod +x install.sh
./install.sh
```

The script will:
1. Detect your OS and distribution
2. Install required packages (tmux, neovim, kitty, zsh, node, npm)
3. Install Nerd Fonts
4. Install Oh My Zsh with popular plugins
5. Backup existing configurations
6. Install new configurations
7. Set up shell integrations

### macOS-Specific Notes

On macOS, the script will:
- Install Homebrew if not already installed
- Automatically configure Homebrew PATH for both Apple Silicon and Intel Macs
- Install Node.js (required for Neovim LSP servers via Mason)
- Install all required packages via Homebrew

**Important for macOS users:**
- After installation, **restart your terminal** or run `source ~/.zshrc` to load the new PATH
- Tmux plugins are NOT auto-installed. You must:
  1. Start tmux: `tmux`
  2. Press `Ctrl+b` then `Shift+i` to install plugins
- Mason LSP servers require Node.js which is now included in the installation
- Verify node is working: `node --version` and `npm --version`

### Manual Installation

If you prefer to install manually or customize the process:

1. **Install dependencies**:
   ```bash
   # Ubuntu/Debian
   sudo apt install tmux neovim kitty git curl build-essential ripgrep fd-find zsh unzip
   curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
   sudo apt install -y nodejs

   # Fedora
   sudo dnf install tmux neovim kitty git curl gcc make ripgrep fd-find zsh unzip nodejs npm

   # Arch
   sudo pacman -S tmux neovim kitty git curl base-devel ripgrep fd zsh unzip nodejs npm

   # macOS
   brew install tmux neovim kitty git curl ripgrep fd zsh node
   ```

2. **Install configurations**:
   ```bash
   # Tmux
   cp tmux.conf ~/.tmux.conf
   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

   # Neovim
   cp -r nvim ~/.config/nvim

   # Kitty
   cp -r kitty ~/.config/kitty
   ```

3. **Install fonts**:
   - Download Mononoki Nerd Font from [Nerd Fonts releases](https://github.com/ryanoasis/nerd-fonts/releases)
   - Install to your system fonts directory

## Post-Installation

### 1. Switch to Zsh (if Oh My Zsh was installed)
```bash
exec zsh
# To make it your default shell:
chsh -s $(which zsh)
```

### 2. Reload Shell Configuration
```bash
source ~/.zshrc
```

### 3. Install Tmux Plugins
```bash
tmux
# Press: Ctrl+b then Shift+i
```

### 4. Install Neovim Plugins
```bash
nvim
# Plugins will auto-install via lazy.nvim
# Wait for completion, then restart nvim
```

### 5. Verify Installation
```bash
# Check installed versions
tmux -V
nvim --version
kitty --version
zsh --version
```

## Key Bindings

### Tmux

**Prefix**: `Ctrl+b`

#### Window Management
- New window: `Prefix + c`
- Next window: `Prefix + n`
- Previous window: `Prefix + p`
- Close window: `Prefix + &`

#### Pane Management
- Split horizontal: `Prefix + |`
- Split vertical: `Prefix + -`
- Navigate panes: `Prefix + h/j/k/l` or just `h/j/k/l` after prefix
- Resize panes: `Prefix + H/J/K/L` (capital letters)
- Close pane: `Prefix + x`

#### Session Management
- New session: `tmux new -s <name>`
- List sessions: `Prefix + s`
- Detach: `Prefix + d`
- Attach: `tmux attach -t <name>`

#### Copy Mode (Vi mode)
- Enter copy mode: `Prefix + [`
- Start selection: `v`
- Copy selection: `y`
- Rectangle selection: `Ctrl+v`
- Paste: `Prefix + ]`

#### Other
- Reload config: `Prefix + r`
- Command prompt: `Prefix + :`

### Neovim

**Leader**: `Space`

#### File Operations
- File explorer: `Leader + e`
- Find files: `Leader + sf`
- Recent files: `Leader + s.`
- Live grep: `Leader + sg`
- Find in current buffer: `Leader + /`

#### LSP Operations
- Go to definition: `grd`
- Go to references: `grr`
- Go to implementation: `gri`
- Rename: `grn`
- Code action: `gra`
- Format: `Leader + f`

#### Git Operations
- Git status: `:Git` or `:G`
- Git diff: `:Gdiffsplit`
- Git blame: `:Git blame`

#### Terminal
- Toggle terminal: `Ctrl+\`

#### Folding
- Open all folds: `zR`
- Close all folds: `zM`

#### Window Navigation
- Move focus left: `Ctrl+h`
- Move focus down: `Ctrl+j`
- Move focus up: `Ctrl+k`
- Move focus right: `Ctrl+l`

#### Other
- Comment: `gcc` (line), `gc` (visual)
- Surround: `ys<motion><char>` (add), `ds<char>` (delete), `cs<old><new>` (change)

### Kitty

#### Tab Management
- New tab: `Ctrl+Shift+t`
- Close tab: `Ctrl+Shift+w`
- Next tab: `Ctrl+Shift+Right`
- Previous tab: `Ctrl+Shift+Left`

#### Window Management
- New window: `Ctrl+Shift+Enter`
- Next window: `Ctrl+Shift+]`
- Previous window: `Ctrl+Shift+[`

#### Font Size
- Increase: `Ctrl+Shift+=`
- Decrease: `Ctrl+Shift+-`
- Reset: `Ctrl+Shift+0`

#### Clipboard
- Copy: `Ctrl+Shift+c`
- Paste: `Ctrl+Shift+v`

#### Scrolling
- Scroll up: `Ctrl+Shift+k`
- Scroll down: `Ctrl+Shift+j`

## Configuration Files

```
my-terminal/
├── install.sh              # Installation script
├── README.md              # This file
├── tmux.conf              # Tmux configuration
├── kitty/
│   ├── kitty.conf         # Kitty configuration
│   └── theme.conf         # Catppuccin theme
└── nvim/
    ├── init.lua           # Main Neovim config
    └── lua/
        ├── custom/
        │   └── plugins/
        │       └── init.lua  # Custom plugins
        └── kickstart/
            └── plugins/      # Kickstart plugins
```

## Customization

### Changing Theme

All configurations use Catppuccin Mocha. To change:

1. **Neovim**: Edit `nvim/init.lua`, search for "catppuccin"
2. **Tmux**: Edit `tmux.conf`, change `@plugin 'catppuccin/tmux'`
3. **Kitty**: Replace `kitty/theme.conf`

### Adding Neovim Plugins

Add plugins to `nvim/lua/custom/plugins/init.lua`:

```lua
return {
  {
    'author/plugin-name',
    config = function()
      require('plugin-name').setup()
    end,
  },
}
```

### Adding Tmux Plugins

Add to `tmux.conf`:

```bash
set -g @plugin 'plugin/name'
```

Then run `Prefix + Shift+i` to install.

## Troubleshooting

### Mason LSP servers not installing
```bash
# Verify Node.js and npm are in PATH
node --version
npm --version

# If "command not found", restart your terminal or reload zsh config:
source ~/.zshrc

# macOS: If still not working, ensure Homebrew PATH is set
# For Apple Silicon:
eval "$(/opt/homebrew/bin/brew shellenv)"
# For Intel Mac:
eval "$(/usr/local/bin/brew shellenv)"

# Then in Neovim, run
:Mason
# Select the LSP server and press 'i' to install
```

### Tmux plugins not loading
```bash
# Reinstall TPM
rm -rf ~/.tmux/plugins/tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Then press Prefix + Shift+i in tmux
```

### Neovim issues
```bash
# Check health (this will show if Node.js/npm is missing)
nvim +checkhealth

# Clear plugin cache
rm -rf ~/.local/share/nvim
rm -rf ~/.cache/nvim
```

### Fonts not working
- Ensure Nerd Font is installed
- Restart your terminal
- Check terminal font settings
- Verify with: `echo -e "\ue0b0 \u00b1 \ue0a0 \u27a6 \u2718 \u26a1 \u2699"`

### Colors not displaying correctly
```bash
# Test true color support
curl -s https://raw.githubusercontent.com/JohnMorales/dotfiles/master/colors/24-bit-color.sh | bash

# Ensure TERM is set correctly
echo $TERM  # Should be "tmux-256color" in tmux or "xterm-256color" in terminal
```

## Enhancements Over Default

### Tmux
- ✅ Vi mode for copy/paste
- ✅ Intuitive pane splitting (| and -)
- ✅ Vim-like pane navigation
- ✅ Session persistence and auto-restore
- ✅ Better status bar with directory info
- ✅ Improved key bindings
- ✅ FZF integration for links

### Neovim
- ✅ Relative line numbers
- ✅ Smooth scrolling
- ✅ Better folding
- ✅ Toggle terminal
- ✅ Git integration
- ✅ Color highlighting
- ✅ Auto-save support
- ✅ Enhanced commenting
- ✅ Indent guides
- ✅ Custom surround

### Kitty
- ✅ Better keyboard shortcuts
- ✅ Copy on select
- ✅ URL detection
- ✅ Shell integration
- ✅ Better tab management
- ✅ Performance optimizations

### Oh My Zsh
- ✅ Auto-suggestions from history
- ✅ Syntax highlighting for commands
- ✅ Enhanced tab completions
- ✅ Git status in prompt
- ✅ 300+ plugins available
- ✅ Easy theme customization
- ✅ Command aliases and shortcuts

## Resources

- [Neovim Documentation](https://neovim.io/doc/)
- [Tmux Manual](https://man.openbsd.org/tmux.1)
- [Kitty Documentation](https://sw.kovidgoyal.net/kitty/)
- [Oh My Zsh](https://ohmyz.sh/)
- [Kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)
- [Catppuccin Theme](https://github.com/catppuccin/catppuccin)
- [Nerd Fonts](https://www.nerdfonts.com/)

## Contributing

Feel free to customize this setup to your needs! This configuration is meant to be a starting point for your perfect terminal environment.

## License

MIT License - Feel free to use and modify as you wish.

---

**Enjoy your enhanced terminal experience!** 🚀
