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

tar -cvzf /tmp/respaldo.tar.gz $folder
i=1
fecha=$(date +"%d-%m-%y_%H-%M")
false
while [ $? -ne 0 -o $i -eq 10 ]; do
    let i++
    scp /tmp/respaldo.tar.gz ${user:-root}@${host:-localhost}:~/"respaldo${fecha}.tar.gz"
done
if [ $i -eq 10 ]; then
    logError "No se pudo hacer el respaldo a ${user}@${host}... ¿Probablemente esté caído?"
else
    log "Respaldo hecho ${user}@${host}: $fecha"
    rm /tmp/respaldo.tar.gz
fi