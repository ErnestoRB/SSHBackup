folder="/etc/ssh-backup"
if [ ! -d $folder ]; then
    mkdir $folder
    if [ $? -eq 0]; then
        echo "No se tienen permisos para crear folders en $(dirname $folder)"
        exit 1
    fi
fi
if [ ! -w $folder ]; then
    echo "No se tienen permisos para crear archivos en $folder"
    exit 1
fi
config="/etc/ssh-backup/config"
if [ ! -e $config ]; then
    echo "user=root" >$config
    echo "host=localhost" >>$config
fi

user=$( cat $config | awk -F"=" '/=/ && $1 == "user" { echo $2 }' )
host=$( cat $config | awk -F"=" '/=/ && $1 == "host" { echo $2 }' )

tar -cvzf /tmp/respaldo.tar.gz /var/www
i=1
false
while [ $? -ne 0 -o $i -eq 10 ]; do
    let i++
    scp respaldo.tar.gz ${user:-root}@${host:-localhost}:~
done
if [ $i -eq 10]; then
    echo "No se pudo hacer el respaldo a ${user}@${host}... ¿Probablemente esté caído?"
fi
rm /tmp/respaldo.tar.gz
