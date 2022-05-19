folder="/etc/ssh-backup"
config="/etc/ssh-backup/config"

# if [ $(id -u) -ne 1 ]; then
#    echo "Se ocupan permisos de root"
#    exit 1
# fi

echo "A continuación se pedirá acceso root para la creación de configuración"
if [ ! -d $folder]; then
    sudo mkdir -p $folder
    sudo touch $config
    sudo chmod o=rwx $config
fi

if [ ! -e ~/.ssh/id_rsa ]; then
    echo "Creando clave rsa"
    ssh-keygen -f ~/.ssh/id_rsa -P ""
    if [ $? -eq 0 ]; then
        echo "Hecho."
    else
        echo "No se pudo crear la clave"
        exit 1
    fi
fi

echo "Por favor, ingresa el usuario del servidor"
read user
echo "Ahora ingresa el host del servidor"
read host

ssh-copy-id -i ~/.ssh/id_rsa.pub ${user}@${host}


