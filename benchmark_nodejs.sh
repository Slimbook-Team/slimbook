#!/bin/bash
# SLIMBOOK TEAM 2021

# instructions:
# open a terminal and run:
# wget https://raw.githubusercontent.com/slimbook/slimbook/master/benchmark_nodejs.
# Exec:
# bash benchmark_nodejs.sh
# Use --loop parameter to loop execution; stop loop pressing Ctrl+C
# wait 10 minutes (or more)
# share your result with us, twitter: @SlimbookES

VERSION='14.19.1'
THREADS=$(lscpu | grep -E '^CPU\(s\)\:' | awk '{print $2}')
CPU=$(grep 'model name' /proc/cpuinfo | head -1 | cut -d ':' -f2)
CURDIR="$PWD"
RESULT=''

cd /tmp || exit # && echo "We are now in $PWD"
echo "Starting execution..."

# if ! test -f "$FILE"; 
# then
# 	echo "$FILE does not exists."
# 	wget https://github.com/nodejs/node/archive/refs/tags/v14.17.3.tar.gz
# fi

DOWNLOAD_FILE="https://github.com/nodejs/node/archive/refs/tags/v${VERSION}.tar.gz"
FILE="/tmp/v${VERSION}.tar.gz"
if ! test -f "$FILE"; 
then
    wget $DOWNLOAD_FILE
    rs=$?
    if [[ $rs -ne 0 || ! -f "v${VERSION}.tar.gz" ]]
    then
        echo "Can not download"
        exit 1
    fi
fi

clean_test(){
    if [[ -d "/tmp/node-${VERSION}" ]]
    then
        rm -rf "/tmp/node-${VERSION}"
    fi
    # if [[ -f "/tmp/v${VERSION}.tar.gz" ]]
    # then
    #     rm -f "v${VERSION}.tar.gz"
    # fi
}

funct_compile () {
	
    # Clean before test
    clean_test

    tar xf "/tmp/v${VERSION}.tar.gz"
    cd "node-${VERSION}" || exit
    ./configure

    START_TIME="$(date -u +%s)"
    make -s -j "$THREADS" 2>&1
    END_TIME="$(date -u +%s)"
	
    ELAPSED="$((END_TIME - START_TIME))"
    h=$((ELAPSED / 3600))
    m=$(((ELAPSED % 3600) / 60))
    s=$((ELAPSED % 60))

    RESULT="\nCPU benchmark finished. -- $(date) \nCPU:$CPU \nTotal time (hours:minutes:seconds): $h:$m:$s \n" 
    printf "$RESULT\n"

}

if test $1 && [ $1 = '--loop' ];  
then
	echo "Infinite loop started [ hit CTRL+C to stop]"
	for (( ; ; ))
	do
		funct_compile
		printf "$RESULT" >> ~/nodejsbenchmark_results.txt
        cd /tmp || exit
	done
else
	funct_compile
fi
