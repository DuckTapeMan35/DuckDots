#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(pwd)"
CONFIG_DIR="$HOME/.config"
TMP_DIR="$(mktemp -d)"

cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

log() {
    echo -e "\n==> $1"
}

# -----------------------------
# Packages
# -----------------------------
log "Installing packages"
yay -S --needed --noconfirm \
    hyprshot hyprpicker mpd qt6ct themix-full-git rose-pine-hyprcursor \
    npm nerd-fonts wl-clipboard lazygit chromium vesktop-bin neovim \
    yazi zathura wofi waybar swww python python-pywal16-git \
    python-haishoku fastfetch kitty kvantum rofi swaync wlogout \
    fish python-pywalfox

# -----------------------------
# OpenRGB keyboard highlighter
# -----------------------------
log "Installing OpenRGB keyboard highlighter"
git clone https://github.com/DuckTapeMan35/orkh "$TMP_DIR/orkh"
(
    cd "$TMP_DIR/orkh"
    ./setup.sh
)

# -----------------------------
# Oh My Fish + theme
# -----------------------------
log "Installing Oh My Fish"
if ! command -v omf >/dev/null; then
    curl -fsSL https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
fi
fish -c "omf install bobthefish"

# -----------------------------
# Config files
# -----------------------------
log "Installing config files"
mkdir -p "$CONFIG_DIR"

for dir in fastfetch fish kitty nvim rofi swaync quickshell wlogout wofi yazi; do
    rm -rf "$CONFIG_DIR/$dir"
    cp -r "$REPO_ROOT/$dir" "$CONFIG_DIR/"
done

# -----------------------------
# Pywal templates
# -----------------------------
log "Installing pywal templates"
mkdir -p "$CONFIG_DIR/wal/templates"
cp -r "$REPO_ROOT/wal_templates/"* "$CONFIG_DIR/wal/templates/"

# -----------------------------
# bgchanger script
# -----------------------------
log "Installing bgchanger"
sudo install -Dm755 "$REPO_ROOT/bgchanger" /usr/bin/bgchanger

# -----------------------------
# Pywalfox
# -----------------------------
log "Installing pywalfox"
pywalfox install

# -----------------------------
# Pywal Discord
# -----------------------------
log "Installing pywal-discord"
git clone https://github.com/franekxtb/pywal-discord "$TMP_DIR/pywal-discord"
(
    cd "$TMP_DIR/pywal-discord"
    sudo ./install.sh
    sudo install -Dm644 \
        "$REPO_ROOT/discord/pywal-discord-duck.css" \
        /usr/share/pywal-discord/pywal-discord-duck.css
)

# -----------------------------
# Libadwaita pywal
# -----------------------------
log "Installing pywal16-libadwaita"
git clone https://github.com/eylles/pywal16-libadwaita "$TMP_DIR/libadwaita"
(
    cd "$TMP_DIR/libadwaita"
    make
)

# -----------------------------
# Environment variables
# -----------------------------
log "Setting QT platform theme"
if ! grep -q "QT_QPA_PLATFORMTHEME=qt6ct" /etc/environment; then
    echo "QT_QPA_PLATFORMTHEME=qt6ct" | sudo tee -a /etc/environment >/dev/null
fi

# -----------------------------
# Hyprland plugins
# -----------------------------
log "Installing Hyprland dynamic cursors"
hyprpm add https://github.com/virtcode/hypr-dynamic-cursors || true
hyprpm enable dynamic-cursors || true

log "Done"

