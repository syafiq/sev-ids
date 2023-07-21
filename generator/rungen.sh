#!/bin/bash

for iter in 1 2 3
do
	outfile="/home/syafiq/sev-ids/generator/outiperf_$iter.log"
	touch $outfile
	/usr/bin/cat /dev/null > $outfile
	echo "Iteration $iter starts"
	echo "***************"
	for cpusnort in 1 2
	do 
		for rules in 0 1 10 100 1000 3462
		do	
			for tcpflows in 1 2 4 8 16
			do
				for psize in 128 256 512 1024 1448
				do
					echo "Starting simulation with cpusnort $cpusnort psize $psize tcpflows $tcpflows rules $rules"
					echo "====================================================================="
					ulimit -n 100000
					/usr/bin/taskset --cpu-list 0-1 /usr/local/bin/iperf -c 192.168.56.10 -t 130 -n $((16/$tcpflows))G -b 500m -l $psize -M $((psize+12)) -P $tcpflows -p 5001 -e >> $outfile &
					/usr/bin/sleep 10
					/usr/bin/taskset --cpu-list 32 /usr/bin/ssh -p 2222 root@127.0.0.1 "ulimit -n 100000"
					if [ $cpusnort -eq 1 ]
					then
						if [ $rules -eq 0 ]
						then
							/usr/bin/taskset --cpu-list 32 /usr/bin/ssh -p 2222 root@127.0.0.1 "/usr/bin/taskset --cpu-list 7 /home/syafiq/snort3-3.1.64.0/build/src/snort --daq afpacket -i enp0s3 --daq-var buffer_size_mb=512 -z $cpusnort -A fast" &
						else
							/usr/bin/taskset --cpu-list 32 /usr/bin/ssh -p 2222 root@127.0.0.1 "/usr/bin/taskset --cpu-list 7 /home/syafiq/snort3-3.1.64.0/build/src/snort --daq afpacket -i enp0s3 --daq-var buffer_size_mb=512 -z $cpusnort -c /home/syafiq/snort3-3.1.64.0/lua/snort.lua -R /home/syafiq/rules/community_$rules.rules -A fast" &
						fi
					elif [ $cpusnort -eq 2 ]
					then
						if [ $rules -eq 0 ]
						then
							/usr/bin/taskset --cpu-list 32 /usr/bin/ssh -p 2222 root@127.0.0.1 "/usr/bin/taskset --cpu-list 0-7 /home/syafiq/snort3-3.1.64.0/build/src/snort --daq afpacket -i enp0s3 --daq-var buffer_size_mb=512 -z $cpusnort -A fast" &
						else
							/usr/bin/taskset --cpu-list 32 /usr/bin/ssh -p 2222 root@127.0.0.1 "/usr/bin/taskset --cpu-list 0-7 /home/syafiq/snort3-3.1.64.0/build/src/snort --daq afpacket -i enp0s3 --daq-var buffer_size_mb=512 -z $cpusnort -c /home/syafiq/snort3-3.1.64.0/lua/snort.lua -R /home/syafiq/rules/community_$rules.rules -A fast" &
						fi
					fi
					/usr/bin/sleep 120
					/usr/bin/killall -9 iperf 
		 			/usr/bin/taskset --cpu-list 32 /usr/bin/ssh -p 2222 root@127.0.0.1 "/usr/bin/killall snort" 
					echo "====================================================================="
					echo "Ending simulation with cpusnort $cpusnort psize $psize tcpflows $tcpflows rules $rules"
					/usr/bin/sleep 10
				done
			done
		done
	done
	echo "***************"
	echo "Iteration $iter done"
done
