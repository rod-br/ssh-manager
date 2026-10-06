<div align="center">

```
         _
 ___ ___| |__        _ __ ___   __ _ _ __   __ _  __ _  ___ _ __
/ __/ __| '_ \ _____| '_ ` _ \ / _` | '_ \ / _` |/ _` |/ _ \ '__|
\__ \__ \ | | |_____| | | | | | (_| | | | | (_| | (_| |  __/ |
|___/___/_| |_|     |_| |_| |_|\__,_|_| |_|\__,_|\__, |\___|_|
                                                 |___/
```

# ssh-manager

**Tus conexiones SSH en un solo script. Sin apps pesadas, sin dependencias.**

![Bash](https://img.shields.io/badge/bash-script-4EAA25?logo=gnubash&logoColor=white)
![OpenSSH](https://img.shields.io/badge/OpenSSH-nativo-blue)
![Dependencias](https://img.shields.io/badge/dependencias-0-success)
![Plataforma](https://img.shields.io/badge/Linux%20%7C%20macOS-lightgrey)
![Licencia](https://img.shields.io/badge/licencia-MIT-yellow)

</div>

---

## ¿Por qué existe?

Los gestores de conexiones gráficos son cómodos hasta que dejan de serlo: pesan
cientos de megas, guardan tus servidores en un formato propio, piden cuenta o
sincronización, y el día que cambiás de máquina hay que exportar, importar y rezar.

**ssh-manager prioriza lo contrario:** dejar de depender de gestores pesados y
pasar a un script simple que te ahorra tiempo y errores.

- **No reemplaza a SSH, lo configura.** Cada conexión es un archivo de texto en
  `~/.ssh/config.d/`, en el formato estándar de OpenSSH.
- **Te conectás con `ssh nombre`.** Desde cualquier terminal, y también funcionan
  `scp`, `rsync`, `git` y el Remote-SSH de tu editor, porque todos leen esa config.
- **Menos errores.** No más IPs, puertos y rutas de claves tipeados de memoria:
  se cargan una vez, validados, y listo.
- **Si lo desinstalás, no perdés nada.** Tus conexiones siguen funcionando: son
  config de SSH, no datos de una app.

| | Gestor gráfico típico | ssh-manager |
|---|---|---|
| Tamaño | Cientos de MB | Un script de bash |
| Dependencias | Runtime propio, a veces una cuenta | bash + OpenSSH (ya los tenés) |
| Formato de datos | Propio | `~/.ssh/config` estándar |
| Uso fuera de la app | No | `ssh`, `scp`, `rsync`, `git`, editores |
| Backup | Exportar / importar | Copiar una carpeta |

## Qué hace

```
  1) Conectar
  2) Registrar conexión
  3) Ver conexiones
  4) Modificar conexión
  5) Renombrar conexión
  6) Eliminar conexión
  7) Claves SSH (guía paso a paso / generar)
  8) Migrar a otra PC (guía paso a paso)
  0) Salir
```

- **Registrar** una conexión con alias, usuario, host, puerto y clave. Al terminar
  ofrece copiar tu clave pública al servidor con `ssh-copy-id`.
- **Conectar, modificar, renombrar y eliminar** eligiendo por número o por nombre.
- **Renombrar** cambia el alias sin tocar el resto de la conexión.
- **Modificar** solo cambia lo que editás: si agregaste opciones a mano
  (`ProxyJump`, `ForwardAgent`, etc.) se conservan.
- **Guía de claves**: si detecta que no tenés un par de claves, te explica paso a
  paso cómo crearlo y puede generarlo por vos con `ssh-keygen`.
- **Guía de migración**: los pasos para llevarte todo a otra PC, con el comando
  de backup ya armado con tus claves.
- **Valida lo que escribís** (nombre, host, puerto) antes de guardar, para que una
  entrada mal tipeada no rompa tu config de SSH.

## Instalación

```bash
git clone https://github.com/rod-br/ssh-manager.git
cd ssh-manager
./install.sh
```

Copia el script a `~/.local/bin` y, si hace falta, agrega esa carpeta al `PATH`
de tu shell (zsh o bash). Después:

```bash
ssh-manager
```

¿No querés instalar nada? También corre directo: `./ssh-manager`.

## Uso

Registrás una conexión una sola vez:

```
== Registrar conexión ==

Nombre/alias: prod
Usuario: deploy
IP / dominio: 203.0.113.10
Puerto [22]:

Claves disponibles:
  /home/vos/.ssh/id_ed25519

Clave privada [/home/vos/.ssh/id_ed25519]:

✔ Conexión 'prod' creada: deploy@203.0.113.10:22
  Para conectarte:  ssh prod
```

Y a partir de ahí, desde cualquier terminal:

```bash
ssh prod
scp backup.tar.gz prod:/tmp/
rsync -av ./dist/ prod:/var/www/
```

## ¿No tenés claves SSH?

No hace falta saberlo de antemano: ssh-manager lo detecta, te avisa en el menú y
te guía. El resumen:

1. **Generar el par** (privada + pública):
   ```bash
   ssh-keygen -t ed25519
   ```
2. **Quedan dos archivos:** `~/.ssh/id_ed25519` (privada, no sale nunca de tu
   máquina) y `~/.ssh/id_ed25519.pub` (pública, es la que va al servidor).
3. **Copiar la pública al servidor** (pide su contraseña una sola vez):
   ```bash
   ssh-copy-id -i ~/.ssh/id_ed25519.pub usuario@servidor
   ```
4. **Probar:** `ssh <alias>` ya no debería pedir la contraseña del servidor.

Los pasos 1 y 3 los puede ejecutar el propio ssh-manager.

## Cómo funciona

```
~/.ssh/
├── config              ← una línea al principio: Include ~/.ssh/config.d/*.conf
└── config.d/
    ├── prod.conf       ← una conexión = un archivo
    └── staging.conf
```

Cada archivo es config de OpenSSH, sin nada propio:

```sshconfig
Host prod
    HostName 203.0.113.10
    User deploy
    Port 22
    IdentityFile "~/.ssh/id_ed25519"
    IdentitiesOnly yes
```

- Tu `~/.ssh/config` existente no se pisa: solo se agrega el `Include` al
  principio (y se deja una copia en `~/.ssh/config.bak` la primera vez).
- Los archivos se crean con permisos `600` y las carpetas con `700`.
- Las claves privadas nunca se copian ni se mueven: solo se guarda su ruta.
- La ruta de la clave se guarda como `~/...`, así la conexión sirve igual en otra
  máquina aunque tu usuario se llame distinto.

## Migrar a otra PC

Como las conexiones son archivos de texto, migrar es copiarlos. La opción 8 del
menú muestra estos pasos con el comando ya armado para tus claves.

1. **En la PC vieja**, empaquetar conexiones y claves:
   ```bash
   tar czf ssh-backup.tar.gz -C ~ .ssh/config.d .ssh/id_ed25519 .ssh/id_ed25519.pub
   ```
2. **Pasar `ssh-backup.tar.gz` a la PC nueva** por pendrive o `scp` dentro de tu
   red. Lleva tus claves privadas: no lo mandes por mail ni chat, no lo subas a
   la nube y borralo al terminar.
3. **En la PC nueva**, instalar ssh-manager y restaurar:
   ```bash
   git clone https://github.com/rod-br/ssh-manager.git
   ./ssh-manager/install.sh
   tar xzpf ssh-backup.tar.gz -C ~
   ssh-manager
   ```
   Al abrirlo, ssh-manager agrega el `Include` a `~/.ssh/config` y corrige los
   permisos de las carpetas.
4. **Probar:** `ssh <alias>`.
   - Si dice `UNPROTECTED PRIVATE KEY FILE`: `chmod 600 ~/.ssh/<clave>`.
   - Si no encuentra la clave (la ruta o el usuario cambiaron): corregila con
     la opción 4 (Modificar).

**¿Preferís no mover las claves privadas?** Es lo más seguro. Empaquetá solo
`.ssh/config.d`, generá un par nuevo en la PC nueva (opción 7) y, desde la PC
vieja, autorizá su `.pub` en cada servidor:

```bash
ssh-copy-id -f -i <clave-nueva>.pub <alias>
```

## Desinstalar

```bash
rm ~/.local/bin/ssh-manager
```

Tus conexiones siguen funcionando con `ssh <alias>`. Para borrarlas también,
eliminá `~/.ssh/config.d/` y la línea `Include` de `~/.ssh/config`.

## Desarrollo

```bash
./test.sh
```

Corre el flujo completo (registrar, renombrar, modificar, eliminar, migrar, validaciones)
contra un `HOME` temporal, sin tocar tu `~/.ssh` real.

## Licencia

[MIT](LICENSE)
