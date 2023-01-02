#!/bin/bash
printf "
 ███████ ██      ██ ███    ███ ██████   ███████   ███████  ██   ██ 
██       ██      ██ ████  ████ ██   ██ ██     ██ ██     ██ ██  ██  
 ██████  ██      ██ ██ ████ ██ ██████  ██     ██ ██     ██ █████   
      ██ ██      ██ ██  ██  ██ ██   ██ ██     ██ ██     ██ ██  ██  
███████  ███████ ██ ██      ██ ██████   ███████   ███████  ██   ██                                              
"
lsb_release -ar 2>/dev/null
echo "Kernel version: $(uname -r)" 
echo "Session type:   $XDG_SESSION_TYPE"

echo	

free -h

echo

lsblk /dev/sd* 2>/dev/null
lsblk /dev/nvme* 2>/dev/null
