for cpusnort in 1 2 
do 
	for psize in 64 128 256 512 1024
	do	
		for tcpflows in 256 1000 4000 8000 16000 32000
		do
			for rules in 1 10 100 1000 3462
			do
				echo "Starting simulation with cpusnort $cpusnort psize $psize tcpflows $tcpflows rules $rules"
				echo "====================================================================="
				ulimit -n 100000
				/usr/bin/cat /dev/null > /home/syafiq/outiperf.log
				/usr/bin/taskset --cpu-list 0-31 /usr/local/bin/iperf -c 192.168.56.10 -t 150 -l $psize -P 32 -p 5001 --reportexclude CDMSV --no-connect-sync --working-load=up,$tcpflows > /home/syafiq/outiperf.log &
				/usr/bin/sleep 30
				/usr/bin/taskset --cpu-list 32 /usr/bin/ssh -p 2222 root@127.0.0.1 "ulimit -n 100000"
				/usr/bin/taskset --cpu-list 32 /usr/bin/ssh -p 2222 root@127.0.0.1 "/usr/bin/taskset --cpu-list 4-7 /home/syafiq/snort3-3.1.64.0/build/src/snort --daq afpacket -i enp0s3 --daq-var buffer_size_mb=512 -z $cpusnort -c /home/syafiq/snort3-3.1.64.0/lua/snort.lua -R /home/syafiq/rules/community_$rules.rules -A fast" &
				/usr/bin/sleep 120
				/usr/bin/killall -9 iperf &
	 			/usr/bin/taskset --cpu-list 32 /usr/bin/ssh -p 2222 root@127.0.0.1 '/usr/bin/killall snort' &
				echo "====================================================================="
				echo "Ending simulation with cpusnort $cpusnort psize $psize tcpflows $tcpflows rules $rules"
				/usr/bin/sleep 10
			done
		done
	done
done
