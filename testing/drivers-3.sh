#!/bin/bash
model(){ # Ciertos modelos necesitan el controlador qc71
    if [ "$(grep -E 'Prox|Executive|Titan|Hero|EVO|CREA' /sys/class/dmi/id/product_name)" ]; then
        eval "$1"
    fi
    if [ $(grep EVO /sys/class/dmi/id/product_name) ]; then
        eval "$2"
    fi
    if [ $(grep -E 'EVO|CREA') ] && [ ! $(grep wake /etc/default/grub) ]; then
        valor_actual=$(grep '^GRUB_CMDLINE_LINUX="' /etc/default/grub | cut -d'"' -f2)
        sed -i "s/^GRUB_CMDLINE_LINUX=\".*\"/GRUB_CMDLINE_LINUX=\"${valor_actual} acpi.ec_no_wakeup=1\"/" /etc/default/grub
        eval "$3"
    fi
}

gpu(){ # Los modelos con gráfica dedicada de Nvidia requiren controladores adicionales
    if [ "$(lspci | grep VGA | grep -E 'NVIDIA|nvidia' | grep -E "$1")" ]; then
        eval "$3" # Gráfica Nvidia MX250
    elif [ "$(lspci | grep VGA | grep -E 'NVIDIA|nvidia' | grep -E '3050|3070')" ]; then
        eval "$2" # Gráficas Nvidia RTX 3050 y Nvidia RTX 3070
    elif [ "$(lspci | grep VGA | grep -E 'NVIDIA|nvidia')" ]; then
        eval "$1" # Cualquier gráfica Nvidia
    fi
}

desktop(){ # Se instala en algunas distribuciones el meta paquete para Gnome y Plasma
    case $XDG_SESSION_DESKTOP in
        GNOME|gnome) $1 install slimbook-meta-gnome -y
        gnome-extensions enable appindicatorsupport@rgcjonas.gmail.com ;; # Con escritorio GNOME
        KDE|kde) $1 install slimbook-meta-plasma -y ;; # Con escritorio KDE
    esac
}

if [ ! "$UID" = "0" ]; then # Comprueba si se esta usando sudo o root
    echo Error: Debe usar sudo o root.; exit
fi

case $1 in
    model) model;;
    gpu) gpu;;
    desktop) desktop;;
esac

if [ $(command -v "apt") ]; then # Ubuntu
    if [ "$(grep Name="SlimbookOS" /etc/os-release)" ]; then # && [ "$(grep 24 /etc/os-release)" ]; then
        echo SlimbookOS # SlimbookOS
    elif [ "$(grep ID=Ubuntu /etc/os-release)" ] && [ "$(grep 22 /etc/os-release)" ]; then
        echo Ubuntu 22 # Ubuntu 22
        add-apt-repository ppa:slimbook/slimbook
    elif [ "$(grep ID=Ubuntu /etc/os-release)" ] && [ "$(grep 24 /etc/os-release)" ]; then
        echo Ubuntu 24 # Ubuntu 24
        wget https://raw.githubusercontent.com/Slimbook-Team/slimbook-base-files/main/sources/slimbook.list
        wget https://raw.githubusercontent.com/Slimbook-Team/slimbook-base-files/main/keys/slimbook.gpg
        mv -f slimbook.gpg /etc/apt/trusted.gpg.d
        mv -f slimbook.list /etc/apt/sources.list.d
    elif [ "$(grep ID=Debian /etc/os-release)" ] && [ "$(grep 12 /etc/os-release)" ] || \
        [ "$(grep ID=devuan /etc/os-release)" ] && [ "$(grep 5 /etc/os-release)" ]; then
        echo Debian 12 # Debian 12 y Devuan 5
        apt-key adv --keyserver keyserver.ubuntu.com --recv-keys BE80F1EEB3838E61E42091B378A22399981017FC
        echo 'deb https://ppa.launchpadcontent.net/slimbook/slimbook/ubuntu jammy main
            deb-src https://ppa.launchpadcontent.net/slimbook/slimbook/ubuntu jammy main' > slimbook.list
        mv -f slimbook.list /etc/apt/sources.list.d
        apt install bash-completion -y
        desktop apt
        [ ! "$(grep completion ~/.bashrc)" ] && \
        echo "if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
    fi" >> .bashrc
    gpu "apt install nvidia-driver -y" "apt install nvidia-driver-550-open -y" "apt install nvidia-driver-470 -y"

    elif [ "$(grep ID=Debian /etc/os-release)" ] && [ "$(grep 13 /etc/os-release)" ] || \
        [ "$(grep ID=devuan /etc/os-release)" ] && [ "$(grep 6 /etc/os-release)" ]; then
        echo Debian 13 # Debian 13 y Devuan 6
        wget https://raw.githubusercontent.com/Slimbook-Team/slimbook-base-files/main/sources/slimbook.list
        wget https://raw.githubusercontent.com/Slimbook-Team/slimbook-base-files/main/keys/slimbook.gpg
        mv -f slimbook.gpg /etc/apt/trusted.gpg.d
        mv -f slimbook.list /etc/apt/sources.list.d
        desktop apt
    fi
    apt update
    apt install slimbook-service -y
    model "apt install linux-headers-amd64 slimbook-qc71-dkms -y" "apt install slimbook-yt6801-dkms -y" "update-grub"

elif [ $(command -v "pacman") ]; then # Manjaro
    gpu "mhwd -a pci nonfree 0300"
    model "pacman -S slimbook-qc71-dkms linux-headers-meta dkms --noconfirm"  "pamac install tuxedo-yt6801-dkms-git --no-confirm" "grub-mkconfig -o /boot/grub/grub.cfg"
    pacman -Syyuu slimbook_service python-dateutils --noconfirm

elif [ $(command -v "dnf") ]; then # Fedora
    if [ $(grep ID=Fedora /etc/os-release) ] && [ $(grep 42 /etc/os-release) ]; then
        echo Fedora 42 # Fedora 42
        dnf4 config-manager --add-repo https://download.opensuse.org/repositories/home:/Slimbook/Fedora_42/home:Slimbook.repo
        dnf update -y --refresh
    elif [ $(grep ID=Fedora /etc/os-release) ] && [ $(grep 41 /etc/os-release) ]; then
        echo Fedora 41 # Fedora 41
        dnf4 config-manager --add-repo https://download.opensuse.org/repositories/home:/Slimbook/Fedora_41/home:Slimbook.repo
        dnf update -y --refresh
    fi
    desktop dnf
    dnf install slimbook-service
    model "dnf install slimbook-qc71-kmod slimbook-qc71-kmod-common -y"
    gpu "dnf install akmod-nvidia"
    grub

elif [ $(command -v "zypper") ]; then # OpenSUSE
    zypper ar -f https://download.opensuse.org/repositories/home:/Slimbook/openSUSE_Tumbleweed/ slimbook
    zypper install slimbook-service -y
    model "zypper install slimbook-qc71-kmp -y"
    desktop zypper
    gpu "zypper install openSUSE-repos-Tumbleweed-NVIDIA -y && zypper install-new-recommends --repo repo-non-free -y"
    grub

fi
