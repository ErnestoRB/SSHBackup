## ¿Qué es?
Genera un respaldo de una carpeta (configurable) a otro equipo, a través de conexión SSH.
## ¿Cómo usarlo?
1.	Descargar el código fuente o clonarlo
2.	Abrir una terminal e ir a la ubicación del código fuente
3.	Dar permisos de ejecución al archivo “install.sh” con chmod u+x install.sh
4.	Ejecutar el script con ./install.sh
5.	Seguir las instrucciones del instalador.
## ¿Cómo funciona?
El instalador pregunta por la carpeta en el equipo local de la cual se desea hacer respaldo, y también por los datos del equipo remoto a donde se debe guardar. El instalador mueve el script generador del backup (backup_script.sh) a /usr/bin, y genera una nueva entrada en el crontab para ejecutarse cada 10 minutos. NOTA: actualmente solo es posible la autentificación a través de clave ssh. El servidor debe soportar dicha configuración.

## ¿Cómo configurarse?
Sólo hay 3 parámetros configurables:
-	Usuario del equipo remoto
-	Dirección del equipo remoto
-	Carpeta por respaldar

Estos se configuran en el archivo ubicado en /etc/ssh-backup/config, respetando el formato clave=valor
