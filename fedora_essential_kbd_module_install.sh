#!/bin/bash
sudo dnf install kernel-headers kernel-devel-$(uname -r) dkms
git clone https://github.com/Slimbook-Team/slimbook-keyboard-dkms.git
cd slimbook-keyboard-dkms/slimbook_keyboard-0.0
make
sudo make dkmsinstall
