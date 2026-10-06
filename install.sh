#!/usr/bin/env bash
# Instala ssh-manager en ~/.local/bin y se asegura de que esté en el PATH.
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN="$HOME/.local/bin"
LINE='export PATH="$HOME/.local/bin:$PATH"'

mkdir -p "$BIN"
install -m 755 "$SCRIPT_DIR/ssh-manager" "$BIN/ssh-manager"
echo "ssh-manager instalado en: $BIN/ssh-manager"

case ":$PATH:" in
    *":$BIN:"*)
        echo "Listo. Ejecutá: ssh-manager"
        exit 0
        ;;
esac

case "$(basename "${SHELL:-}")" in
    zsh) RC="$HOME/.zshrc" ;;
    bash) RC="$HOME/.bashrc" ;;
    *)
        echo "Agregá $BIN a tu PATH y ejecutá: ssh-manager"
        exit 0
        ;;
esac

grep -qF "$LINE" "$RC" 2>/dev/null || echo "$LINE" >> "$RC"
echo "PATH configurado en: $RC"
echo
echo "Aplicá el cambio con:"
echo "  source $RC"
echo
echo "Luego ejecutá:"
echo "  ssh-manager"
