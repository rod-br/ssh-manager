SSH Manager - Backup

Contenido:
- ssh-manager: gestor de conexiones SSH.
- install-zsh.sh: instala el gestor en ~/.local/bin y agrega ~/.local/bin al PATH de zsh.

Instalación:
1. Extraer el ZIP.
2. Entrar a la carpeta.
3. Ejecutar:
   chmod +x install-zsh.sh ssh-manager
   ./install-zsh.sh
4. Ejecutar:
   source ~/.zshrc
5. Usar:
   ssh-manager

El gestor usa ~/.ssh/config.d/*.conf y el Include correspondiente en ~/.ssh/config.
No incluye claves privadas ni configuraciones de conexiones existentes.
