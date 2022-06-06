#!/bin/bash
log() {
	PREFIX="[LOG]"
	echo "${PREFIX}: $(date +"%d/%m/%Y %T") -> $*"
}

logError() {
	PREFIX="[ERR]"
	echo "${PREFIX}: $(date +"%d/%m/%Y %T") -> $*" >&2
}

config="/etc/ssh-backup/config"

if [ ! -e $config ]; then
    if [ -w $(dirname $config) ]; then
        echo "user=root" >$config && echo "host=localhost" >>$config && echo "folder=/var/www" >>$config && log "Archivo de configuracion creado"
    else
        logError "No se tienen permisos de escritura sobre el folder $(dirname $config). No se creará archivo de configuración"
    fi
    logError "Se usarán los valores por defecto (user=root, host=localhost, folder=/var/www/)"
    user="root"
    host="localhost"
    folder="/var/www/"
else # leer desde configuracion
    user=$( cat $config | awk -F"=" '/=/ && $1 == "user" { print $2 }' )
    host=$( cat $config | awk -F"=" '/=/ && $1 == "host" { print $2 }' )
    folder=$( cat $config | awk -F"=" '/=/ && $1 == "folder" { print $2 }' )
fi

fecha=$(date +"%d-%m-%y_%H-%M")
if [ ! -e $folder ];
then
    logError "No se pudo hacer el respaldo ya que la carpeta a respaldar (${folder}) no existe!"
    exit 1
fi
tar -czf "/tmp/respaldo${fecha}.tar.gz" $folder
if scp -o ConnectTimeout=1 -o ConnectionAttempts=5 "/tmp/respaldo${fecha}.tar.gz"  scp://${user}@${host}
then
    log "Respaldo hecho ${user}@${host}: $fecha"
    rm "/tmp/respaldo${fecha}.tar.gz"
else
    logError "No se pudo hacer el respaldo a ${user}@${host}... ¿Probablemente esté caído?"
fi