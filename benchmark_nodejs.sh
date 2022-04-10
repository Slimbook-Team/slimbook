#!/bin/bash
# SLIMBOOK TEAM 2021

# instructions:
# open a terminal and run:
# wget https://raw.githubusercontent.com/slimbook/slimbook/master/benchmark_nodejs.sh
# bash benchmark_nodejs.sh
# wait 10 minutes (or more)
# share your result with us, twitter: @SlimbookES

clean_test(){
    if [[ -d "/tmp/node-${VERSION}" ]]
    then
        rm -rf "/tmp/node-${VERSION}"
    fi
    if [[ -f "/tmp/v${VERSION}.tar.gz" ]]
    then
        rm -f "v${VERSION}.tar.gz"
    fi
}


VERSION='14.19.1'

THREADS=$(lscpu | grep -E '^CPU\(s\)\:' | awk '{print $2}')
CPU=$(grep 'model name' /proc/cpuinfo | head -1 | cut -d ':' -f2)
CURDIR="$PWD"

cd /tmp || exit
# Clean before test
clean_test

wget "https://github.com/nodejs/node/archive/refs/tags/v${VERSION}.tar.gz"
rs=$?
if [[ $rs -ne 0 || ! -f "v${VERSION}.tar.gz" ]]
then
    echo "Can not download"
    exit 1
fi

tar xf "v${VERSION}.tar.gz"
cd "node-${VERSION}" || exit

./configure

START_TIME="$(date -u +%s)"
make -s -j "$THREADS" 2>&1
END_TIME="$(date -u +%s)"

ELAPSED="$((END_TIME - START_TIME))"
h=$((ELAPSED / 3600))
m=$(((ELAPSED % 3600) / 60))
s=$((ELAPSED % 60))

printf "\n=== CPU benchmark finished ==="
printf "\nCPU: %s" "$CPU"
printf "\nTotal time (hours:minutes:seconds): %02d:%02d:%02d \n" $h $m $s

# Clean after test
clean_test
cd "$CURDIR"
