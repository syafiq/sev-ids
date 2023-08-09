#!/bin/bash

homedir="/home/syafiq"
taskset="/usr/bin/taskset"
iperf="/usr/local/bin/iperf"
snortbin="$homedir/snort3-3.1.64.0/build/src/snort"
snortdir="$homedir/snort3-3.1.64.0"
ssh="/usr/bin/ssh"
daqdir="/usr/local/lib/daq/"
ruledir="$homedir/rules"
pkill="/usr/bin/pkill"
sshguest="$taskset --cpu-list 32 $ssh -p 2222 root@127.0.0.1"

for iter in 1 2 3
do
	outfile="$homedir/sev-ids/generator/outiperf_$iter.log"
	touch $outfile
	/usr/bin/cat /dev/null > $outfile
	echo "Iteration $iter starts"
	echo "***************"
	for cpusnort in 1 2
	do 
		for rules in 0 
		do	
			for udppps in 100 1000 10000 100000
			do
				for psize in 128 256 512 1024
				do
					header="Starting simulation with cpusnort $cpusnort psize $psize udppps $udppps rules $rules"
					line="====================================================================="
					end="Ending simulation with cpusnort $cpusnort psize $psize udppps $udppps rules $rules"
					snortrun="$snortbin --daq afpacket -i enp0s3 -z $cpusnort"
					snortrun_rules="$snortrun -c $snortdir/lua/snort.lua -R $ruledir/community_$rules.rules"
					ulimit -n 100000
					echo $header >> $outfile
					echo $line >> $outfile
					/usr/sbin/ifconfig tap0 mtu $psize
					$sshguest "/usr/sbin/ifconfig enp0s3 mtu $psize"
					$taskset --cpu-list 0-1 $iperf -c 192.168.56.10 --NUM_REPORT_STRUCTS 20000 -t 140 -l $psize -b $udppps -p 5001 -e >> $outfile &
					/usr/bin/sleep 10
					$sshguest "ulimit -n 100000"
					echo $header
					echo $line
					if [ $cpusnort -eq 1 ]
					then
						if [ $rules -eq 0 ]
						then
							$sshguest "$taskset --cpu-list 7 $snortrun" &
						else
							$sshguest "$taskset --cpu-list 7 $snortrun_rules" &
						fi
					elif [ $cpusnort -eq 2 ]
					then
						if [ $rules -eq 0 ]
						then
							$sshguest "$taskset --cpu-list 6-7 $snortrun" &
						else
							$sshguest "$taskset --cpu-list 6-7 $snortrun_rules" &
						fi
					fi
					/usr/bin/sleep 120
					$pkill -SIGINT -f iperf
		 			$sshguest "$pkill -SIGINT -f snort" 
					/usr/bin/sleep 5
					echo $line
					echo $end
					echo $line >> $outfile
					echo $end >> $outfile
				done
			done
		done
	done
	echo "***************"
	echo "Iteration $iter done"
done
