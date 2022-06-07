#!/bin/bash
# SLIMBOOK TEAM 2021

# instructions:
# open a terminal and run:
# wget https://raw.githubusercontent.com/slimbook/slimbook/master/benchmark_nodejs.sh
# bash benchmark_nodejs.sh
# wait 10 minutes (or more)
# share your result with us, twitter: @SlimbookES

threads=$(lscpu | egrep '^CPU\(s\)\:' | cut -d ':' -f 2)
cpu=$(cat /proc/cpuinfo | grep 'model name' | head -1 | cut -d ':' -f2)
result=''

cd /tmp # && echo "We are now in $PWD"
echo "Starting execution..."

FILE=/tmp/v14.17.3.tar.gz
if ! test -f "$FILE"; 
then
	echo "$FILE does not exists."
	wget https://github.com/nodejs/node/archive/refs/tags/v14.17.3.tar.gz
fi

funct_compile () {
	
	DIR=/tmp/node-14.17.3
	if test -d "$DIR"; 
	then
		# rm -f v14.17.3.tar.gz
		rm -rf node-14.17.3
	fi
	tar xf /tmp/v14.17.3.tar.gz

	cd node-14.17.3 # && echo "We are now in $PWD"
	./configure

	start_time="$(date -u +%s)"
	make -s -j $threads 2>&1 
	sleep 3
	end_time="$(date -u +%s)"
	elapsed="$(($end_time-$start_time))"

	h=$(($elapsed/3600))
	m=$((($elapsed%3600)/60))
	s=$(($elapsed%60))

	cd /tmp # && echo "We are now in $PWD"

	result="\nCPU benchmark finished. -- $(date) \nCPU:$cpu \nTotal time (hours:minutes:seconds): $h:$m:$s \n" 
	printf "$result\n"
	
}

if test $1 && [ $1 = '--loop' ];  
then
	echo "Infinite loop started [ hit CTRL+C to stop]"
	for (( ; ; ))
	do
		funct_compile
		printf "$result" >> ~/nodejsbenchmark_results.txt
	done
else
	funct_compile
fi
	