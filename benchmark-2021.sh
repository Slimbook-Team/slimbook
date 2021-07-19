threads=$(lscpu | egrep 'CPU\(s\)\:' | cut -d ':' -f 2)

wget https://github.com/nodejs/node/archive/refs/tags/v14.17.3.tar.gz 
tar xf v14.17.3.tar.gz 
cd node-14.17.3 
./configure  

start_time="$(date -u +%s)" 
make -s -j $threads 2>&1 end_time="$(date -u +%s)"  

elapsed="$(($end_time-$start_time))"  

echo "Total of $elapsed seconds elapsed for process"
