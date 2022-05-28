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
    echo "user=root" >$config
    echo "host=localhost" >>$config
    echo "folder=/var/www" >>$config
    log "Archivo de configuracion creado"
fi
    
user=$( cat $config | awk -F"=" '/=/ && $1 == "user" { print $2 }' )
host=$( cat $config | awk -F"=" '/=/ && $1 == "host" { print $2 }' )
folder=$( cat $config | awk -F"=" '/=/ && $1 == "folder" { print $2 }' )
tar -czf /tmp/respaldo.tar.gz $folder
fecha=$(date +"%d-%m-%y_%H-%M")
if scp /tmp/respaldo.tar.gz -o ConnectTimeout=1 -o ConnectionAttempts=5 ${user:-root}@${host:-localhost}:~/"respaldo${fecha}.tar.gz"
then
    log "Respaldo hecho ${user}@${host}: $fecha"
    rm /tmp/respaldo.tar.gz
else
    logError "No se pudo hacer el respaldo a ${user}@${host}... ¿Probablemente esté caído?"
fi