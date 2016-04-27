#!/bin/bash

# This file is an adaptation of original script of itadicts, by Slimbook TEAM ( www.slimbook.es )
# LAST UPDATE : 27 April 2016

# COMANDOS	
OLDCONF=$(dpkg -l|grep "^rc"|awk '{print $2}')
CURKERNEL=$(uname -r|sed 's/-*[a-z]//g'|sed 's/-386//g')
LINUXPKG="linux-(image|headers|ubuntu-modules|restricted-modules)"
METALINUXPKG="linux-(image|headers|restricted-modules)-(generic|i386|server|common|rt|xen)"
OLDKERNELS=$(dpkg -l|awk '{print $2}'|grep -E $LINUXPKG |grep -vE $METALINUXPKG|grep -v $CURKERNEL)

# COLORES
AMARILLO="\033[1;33m"
ROJO="\033[0;31m"
COLORFIN="\033[0m"

# PROCESOS
if [ $USER != root ]; then
echo -e $ROJO"Error: se debe ejecutar como root"
echo -e $AMARILLO"Saliendo..."$COLORFIN
exit 0
fi

echo -e "Limpiando la cache apt..."
apt-get -qq clean

echo -e "Eliminando viejos ficheros de configuracion..."
sudo apt-get -qq purge $OLDCONF

echo -e "Eliminando viejos kernels..."
sudo apt-get -qq purge $OLDKERNELS

echo -e "Eliminando los residuos..."
rm -rf /root/.local/share/Trash/*/** &> /dev/null

echo -e "Actualizando el cargador de arranque..."
update-grub

apt-get install linux-generic -y

echo -e "Script ejecutado correctamente"
