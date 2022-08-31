#!/bin/bash
# SLIMBOOK TEAM 2022

# instructions:
# open a terminal and run:
# wget https://raw.githubusercontent.com/slimbook/slimbook/master/executive_edid.sh
# Exec:
# sudo bash executive_edid.sh

DISTRO=$(lsb_release -is)

cd /tmp || exit # && echo "We are now in $PWD"
wget https://raw.githubusercontent.com/slimbook/slimbook/master/assets/executive_edid_mod90hz.bin
sudo mkdir /lib/firmware/edid/
sudo cp /tmp/executive_edid_mod90hz.bin /lib/firmware/edid/edid.bin

sudo sed -i 's%GRUB_CMDLINE_LINUX_DEFAULT="%GRUB_CMDLINE_LINUX_DEFAULT="drm.edid_firmware=eDP-1:edid/edid.bin %g' "/etc/default/grub" #% en lugar de /

wget https://raw.githubusercontent.com/slimbook/slimbook/master/assets/executive_edid_hooks
sudo mkdir /etc/initramfs-tools/hooks/
sudo cp /tmp/executive_edid_hooks /etc/initramfs-tools/hooks/edid
sudo chmod +x /etc/initramfs-tools/hooks/edid

sudo update-initramfs -u
sudo update-grub

#fedora start (y algunos arch)
if [ $DISTRO = "Fedora" ] || [ $DISTRO = "Manjaro" ]; then
  wget https://raw.githubusercontent.com/slimbook/slimbook/master/assets/executive_edid.conf
  sudo cp /tmp/executive_edid.conf /etc/dracut.conf.d/executive_edid.conf
  sudo dracut -f
  sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
  sudo grub2-mkconfig -o /boot/grub/grub.cfg 
fi
#fedora end

echo "Finalizado, reinicie el ordenador para aplicar los cambios"
