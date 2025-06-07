# ~/.config/fish/config.fish

# ===== Aliases =====
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias update='sudo pacman -Syu'
alias yayupdate='yay -Syu'
alias qo='qutebrowser -- open:'

# ===== Startup Command =====
if command -q fastfetch
    fastfetch
end

# ===== Pyenv Setup =====
set -Ux PYENV_ROOT $HOME/.pyenv
fish_add_path $PYENV_ROOT/bin
if command -q pyenv
    pyenv init --path | source
    pyenv init - | source
    # pyenv virtualenv-init - | source
end

# ===== GHCup Setup =====
set -Ux GHCUP_INSTALL_BASE_PREFIX $HOME
fish_add_path $HOME/.cabal/bin
fish_add_path $HOME/.ghcup/bin

# ===== Yazi Function =====
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (cat "$tmp")
        test -n "$cwd"; and test "$cwd" != "$PWD"
        and cd "$cwd"
    end
    rm -f "$tmp"
end

# ===== NVM Setup =====
# Only run fisher if it's installed and we haven't set the flag
if command -q fisher
    if not set -q __nvm_plugin_installed
        # Install the plugin and set flag to prevent re-installation
        fisher install jorgebucaran/nvm.fish
        set -U nvm_default_version lts
        set -gU __nvm_plugin_installed true
    end
end

# ===== Visual Setup =====

set -g theme_color_scheme terminal

set -g theme_display_user yes

set -g theme_display_hostname yes

set -g theme_display_date no

function bobthefish_colors -S -d 'Define a custom bobthefish color scheme'
  set -x color_path_basename 333333 ffffff --bold
  set -x color_path 333333 999999
end
