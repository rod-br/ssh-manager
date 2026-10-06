#!/usr/bin/env bash
# Prueba de punta a punta contra un HOME falso: ./test.sh
set -eu

cd "$(dirname "${BASH_SOURCE[0]}")"
H=$(mktemp -d)
trap 'rm -rf "$H"' EXIT
D="$H/.ssh/config.d"

run() { printf '%s\n' "$@" | HOME="$H" NO_COLOR=1 ./ssh-manager >"$H/out" 2>&1; }
fail() { echo "FALLÓ: $1"; cat "$H/out"; exit 1; }
opt() { ssh -F "$D/$1.conf" -G "$1" 2>/dev/null | sed -n "s/^$2 //p"; }

# Config vieja con el Include al final, dentro de un bloque Host (bug original).
mkdir -p "$H/.ssh"
printf 'Host viejo\n    HostName 1.1.1.1\n\nInclude ~/.ssh/config.d/*.conf\n' > "$H/.ssh/config"

# Sin claves: avisa en el menú y la guía explica el paso a paso.
run 7 n ""
grep -q "No tenés claves SSH" "$H/out" || fail "falta el aviso de claves en el menú"
grep -q "ssh-keygen -t ed25519" "$H/out" || fail "falta la guía de claves"
grep -q "ssh-copy-id" "$H/out" || fail "la guía no explica cómo copiar la pública"

[ "$(grep -n Include "$H/.ssh/config" | cut -d: -f1)" -lt "$(grep -n '^Host' "$H/.ssh/config" | cut -d: -f1)" ] ||
    fail "el Include quedó después del primer Host"
[ "$(grep -c Include "$H/.ssh/config")" = 1 ] || fail "Include duplicado"
grep -q "HostName 1.1.1.1" "$H/.ssh/config" || fail "se perdió la config previa"

ssh-keygen -q -t ed25519 -N '' -f "$H/.ssh/con espacio"

# Registrar (clave por defecto = la detectada), sin copiar la pública.
run 2 web root 10.0.0.1 "" "" n ""
[ "$(opt web hostname)" = 10.0.0.1 ] || fail "registrar: hostname"
[ "$(opt web port)" = 22 ] || fail "registrar: puerto por defecto"
[ "$(opt web identityfile)" = "~/.ssh/con espacio" ] || fail "registrar: clave con espacios, guardada como ~/"
[ "$(stat -c %a "$D/web.conf" 2>/dev/null || stat -f %Lp "$D/web.conf")" = 600 ] || fail "permisos"

# Entradas inválidas no escriben nada.
run 2 ../evil "" 2 ok root "host malo" "" 2 ok2 root h 99999 ""
[ "$(ls "$D")" = web.conf ] || fail "se creó una conexión inválida"

# Renombrar eligiendo por número; una opción agregada a mano se conserva.
echo "    ProxyJump bastion" >> "$D/web.conf"
run 5 1 prod ""
[ ! -e "$D/web.conf" ] && [ "$(head -n1 "$D/prod.conf")" = "Host prod" ] || fail "renombrar"

# Modificar: Enter mantiene, el resto cambia, ProxyJump sigue ahí.
run 4 prod "" example.com 2222 "" ""
[ "$(opt prod user)" = root ] || fail "modificar: no mantuvo el usuario"
[ "$(opt prod hostname)" = example.com ] || fail "modificar: hostname"
[ "$(opt prod port)" = 2222 ] || fail "modificar: puerto"
[ "$(opt prod proxyjump)" = bastion ] || fail "modificar: perdió ProxyJump"

# No se puede pisar otra conexión al renombrar.
run 2 otra root h "" "" n "" 5 otra prod ""
[ -e "$D/otra.conf" ] || fail "renombrar pisó una conexión existente"

run 6 prod s ""
[ ! -e "$D/prod.conf" ] || fail "eliminar"

# Migrar: el comando de backup que muestra la guía funciona y la restauración también.
run 8 ""
(cd "$H" && HOME="$H" eval "$(grep -m1 'tar czf' "$H/out")") || fail "migrar: el comando de backup falla"
mkdir "$H/nueva"
tar xzpf "$H/ssh-backup.tar.gz" -C "$H/nueva"
[ -f "$H/nueva/.ssh/config.d/otra.conf" ] && [ -f "$H/nueva/.ssh/con espacio" ] || fail "migrar: backup incompleto"
printf '0\n' | HOME="$H/nueva" NO_COLOR=1 ./ssh-manager >/dev/null 2>&1
grep -q '^Include' "$H/nueva/.ssh/config" || fail "migrar: la PC nueva quedó sin Include"
[ "$(stat -c %a "$H/nueva/.ssh" 2>/dev/null || stat -f %Lp "$H/nueva/.ssh")" = 700 ] || fail "migrar: permisos de ~/.ssh"
[ "$(stat -c %a "$H/nueva/.ssh/con espacio" 2>/dev/null || stat -f %Lp "$H/nueva/.ssh/con espacio")" = 600 ] || fail "migrar: permisos de la clave"

echo "OK"
