for cpusnort in 1 2 3
do 
	for psize in 64 128 256 512 1024
	do	
		for tcpflows in 256 1000 4000 8000 16000 32000
		do 
			for ratep in 500 1000 1500 2000 2500 3000
			do
				echo "Starting simulation with cpusnort $cpusnort psize $psize tcpflows $tcpflows ratep $ratep"
				echo "====================================================================="
				/usr/bin/taskset --cpu-list 32 /usr/bin/ssh -p 2222 root@127.0.0.1 "/usr/bin/taskset --cpu-list 0 /home/syafiq/snort/bin/snort --daq afpacket -i enp0s3 --daq-var buffer_size_mb=512 -z $cpusnort -A fast" &
	 			/usr/bin/taskset --cpu-list 0-31 /usr/bin/timeout 120 /home/syafiq/sev-ids/generator/generate.sh $psize $ratep $tcpflows
	 			/usr/bin/taskset --cpu-list 32 /usr/bin/ssh -p 2222 root@127.0.0.1 '/usr/bin/killall snort' &
				echo "====================================================================="
				echo "Ending simulation with cpusnort $cpusnort psize $psize tcpflows $tcpflows ratep $ratep"
				/usr/bin/sleep 10
			done
		done
	done
done
