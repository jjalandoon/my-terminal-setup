# Quick Reference Card

## Tmux (Prefix: Ctrl+b)

### Essential Commands
```
Prefix + r          Reload config
Prefix + |          Split horizontal
Prefix + -          Split vertical
Prefix + h/j/k/l    Navigate panes (vim-style)
Prefix + H/J/K/L    Resize panes
Prefix + c          New window
Prefix + [          Copy mode (vi)
Prefix + ]          Paste
Prefix + d          Detach session
Prefix + s          List sessions
```

### Copy Mode (Vi)
```
v                   Begin selection
y                   Copy selection
Ctrl+v              Rectangle selection
q                   Exit copy mode
```

## Neovim (Leader: Space)

### Files & Search
```
<Leader> + e        File explorer
<Leader> + sf       Search files
<Leader> + sg       Live grep
<Leader> + s.       Recent files
<Leader> + /        Search in buffer
```

### LSP
```
grd                 Go to definition
grr                 Go to references
gri                 Go to implementation
grn                 Rename
gra                 Code action
<Leader> + f        Format
```

### Git
```
:Git                Git status
:G                  Git command
:Gdiffsplit         Git diff
```

### Terminal & Windows
```
Ctrl+\              Toggle terminal
Ctrl+h/j/k/l        Navigate windows
gcc                 Comment line
gc                  Comment (visual)
```

### Folding
```
zR                  Open all folds
zM                  Close all folds
za                  Toggle fold
```

## Kitty

### Tabs & Windows
```
Ctrl+Shift+t        New tab
Ctrl+Shift+w        Close tab
Ctrl+Shift+→/←      Next/Prev tab
Ctrl+Shift+Enter    New window
Ctrl+Shift+]/[      Next/Prev window
```

### Clipboard & Font
```
Ctrl+Shift+c        Copy
Ctrl+Shift+v        Paste
Ctrl+Shift+=        Increase font
Ctrl+Shift+-        Decrease font
Ctrl+Shift+0        Reset font
```

### Scrolling
```
Ctrl+Shift+k        Scroll up
Ctrl+Shift+j        Scroll down
```

## Common Workflows

### Start New Project Session
```bash
# Create new tmux session
tmux new -s project-name

# Open neovim
nvim

# Split panes as needed
Prefix + |          # Horizontal split
Prefix + -          # Vertical split
```

### Git Workflow in Neovim
```
<Leader> + e        # Open file explorer
# Edit files
:Git                # Check status
:Git add .          # Stage changes
:Git commit         # Commit
```

### Terminal in Neovim
```
Ctrl+\              # Toggle floating terminal
# Run commands
Ctrl+\              # Close terminal
```

### Save & Exit
```
# Neovim
:w                  # Save
:q                  # Quit
:wq                 # Save and quit
:q!                 # Quit without saving

# Tmux
Prefix + d          # Detach (session continues)
exit                # Exit shell (closes pane)
```

## Tips & Tricks

1. **Tmux Sessions**: Keep multiple projects in separate sessions
   ```bash
   tmux new -s work
   tmux new -s personal
   tmux ls                    # List sessions
   tmux attach -t work        # Attach to session
   ```

2. **Neovim**: Use telescope for everything
   ```
   <Leader> + sh              # Search help
   <Leader> + sk              # Search keymaps
   <Leader> + ss              # Search telescope
   ```

3. **Persistent Tmux**: Sessions auto-restore with continuum
   - Just start tmux, your session will be restored!

4. **Quick Navigation**: Combine tmux panes with vim windows
   - Use tmux for different tasks (code, terminal, logs)
   - Use vim windows/buffers within code pane

5. **Search & Replace in Neovim**:
   ```
   :%s/old/new/g              # Replace in file
   :%s/old/new/gc             # Replace with confirmation
   ```

## Emergency Commands

```bash
# Tmux not responding
Ctrl+b + :
kill-server

# Neovim stuck
:qa!

# Reset terminal
reset

# Reload tmux config
tmux source ~/.tmux.conf

# Restart Kitty
Ctrl+Shift+F5
```

## Health Checks

```bash
# Neovim health
nvim +checkhealth

# Tmux plugin status
Prefix + Shift+u        # Update plugins
Prefix + Shift+i        # Install plugins

# Check colors
echo $TERM
curl -s https://raw.githubusercontent.com/JohnMorales/dotfiles/master/colors/24-bit-color.sh | bash
```
