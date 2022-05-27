#!/bin/bash

folder="/etc/ssh-backup"
config="/etc/ssh-backup/config"
log="/var/log/ssh-backup/log"

# if [ $(id -u) -ne 1 ]; then
#    echo "Se ocupan permisos de root"
#    exit 1
# fi
. logUtils.sh

if [ ! -d $folder ]; then
    logWarn "Se necesitan permisos para crear $folder"
    (sudo mkdir -p $folder;sudo touch $config) && logSuccess "Hecho"
fi

if [ ! -w $config ]; then
    logWarn "Se necesita permisos para editar $config"
    sudo chmod ugo=rwx $config && logSuccess "Hecho"
fi

if [ ! -w /usr/bin ]; then
    logWarn "Se necesitan permisos para copiar script en /usr/bin"
    (sudo cp backup_script.sh /usr/bin; sudo chmod o=rwx /usr/bin/backup_script.sh) && logSuccess "Hecho"
fi

if [ ! -e $log ]; then
    logWarn "Se necesita crear archivo de log"
    (sudo mkdir -p $(dirname $log); sudo touch $log; sudo chmod a=rwx $log) && logSuccess "Hecho"
fi

echo "Consultando si existe clave ssh (id_rsa) disponible..."
if [ ! -e ~/.ssh/id_rsa ]; then
    logWarn "Clave no encontrada, creando clave rsa..."
    ssh-keygen -f ~/.ssh/id_rsa -P ""
    if [ $? -eq 0 ]; then
        logSuccess "Hecho."
    else
        logError "No se pudo crear la clave"
        exit 1
    fi
else
    echo "Clave ya existe, no se creará una nueva."
fi

echo "A continuación se pedirán datos de conexión al servidor al cual se piensa hacer el respaldo"
echo -ne "\e[1;1mUsuario: \e[0m"
read user
echo -ne "\e[1;1mHost: \e[0m"
read host
echo -ne "\e[1;1mQue carpeta de este equipo deseas respaldar? \e[0m"
read folder

echo "A continuación se intentará copiar la clave"
ssh-copy-id -i ~/.ssh/id_rsa.pub ${user}@${host} -o ConnectTimeout=5 # copiar clave publica a servidor
if [ $? -ne 0 ]; then
    logError "Error. Comprueba los datos del servidor"
    exit 1
fi
echo -e "user=${user}\nhost=${host}\nfolder=${folder}" >$config && logSuccess "Ok, configración creada"
if [[ $? -ne 0 || -z $(crontab -l | grep backup_script.sh) ]]; then
    echo "Intentado crear crontab..."
    (cat ejemplo_cront; crontab -l) | crontab
    if [ $? -eq 0 ]; then
        logSuccess "Crontab actualizada."
    else 
        logError "Error al actualizar el crontab"
    fi
fi