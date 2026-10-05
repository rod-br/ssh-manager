#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$HOME/.local/bin/ssh-manager"

mkdir -p "$HOME/.local/bin"
cp "$SCRIPT_DIR/ssh-manager" "$TARGET"
chmod +x "$TARGET"

if ! grep -qF 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.zshrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
fi

echo "ssh-manager instalado en: $TARGET"
echo "PATH configurado en: $HOME/.zshrc"
echo
echo "Aplicá el cambio con:"
echo "  source ~/.zshrc"
echo
echo "Luego ejecutá:"
echo "  ssh-manager"
