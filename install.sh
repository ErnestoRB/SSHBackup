#!/bin/bash

folder="/etc/ssh-backup"
config="/etc/ssh-backup/config"

# if [ $(id -u) -ne 1 ]; then
#    echo "Se ocupan permisos de root"
#    exit 1
# fi

echo "A continuación se pedirá acceso root para la creación de configuración"
if [ ! -d $folder ]; then
    sudo mkdir -p $folder
    sudo touch $config
    sudo chmod =rwx $config
fi

echo "Consultando si existe clave ssh (id_rsa) disponible..."
if [ ! -e ~/.ssh/id_rsa ]; then
    echo "Clave no encontrada, creando clave rsa..."
    ssh-keygen -f ~/.ssh/id_rsa -P ""
    if [ $? -eq 0 ]; then
        echo "Hecho."
    else
        echo "No se pudo crear la clave"
        exit 1
    fi
fi

echo "A continuación se pedirán datos de conexión al servidor al cual se piensa hacer el respaldo"
echo -n "Usuario: "
read user
echo -n "Host:"
read host

echo "A continuación se intentará copiar la clave"
ssh-copy-id -i ~/.ssh/id_rsa.pub ${user}@${host} # copiar clave publica a servidor
if [ $? -ne 0 ]; then
    echo "Error. Comprueba los datos del servidor"
    exit 1
fi
echo -e "user=${user}\nhost=${host}" >$config
echo "Ok, confugración creada"
