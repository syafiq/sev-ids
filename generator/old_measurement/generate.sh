#!/bin/bash

CPUS=32
CLONE_SKB="clone_skb 0"
PKT_SIZE="pkt_size $1"
COUNT="count 0"
DELAY="delay 0"
ETH="tap0"
RATEP="$2"
FLOWS="$3"

function pgset() {
    local result
    echo $1 > $PGDEV
    result=`cat $PGDEV | fgrep "Result: OK:"`
    if [ "$result" = "" ]; then
        cat $PGDEV | fgrep Result:
    fi
}

for ((processor=0;processor<$CPUS;processor++))
do
    PGDEV=/proc/net/pktgen/kpktgend_$processor
    #echo "Removing all devices"
    pgset "rem_device_all"
done

for ((processor=0;processor<$CPUS;processor++))
do
    PGDEV=/proc/net/pktgen/kpktgend_$processor
    #echo "Adding $ETH"
    pgset "add_device $ETH@$processor"
    PGDEV=/proc/net/pktgen/$ETH@$processor
    #echo "Configuring $PGDEV"
    pgset "$COUNT"
    pgset "flag QUEUE_MAP_CPU"
    pgset "$CLONE_SKB"
    pgset "frags 10"
    pgset "$PKT_SIZE"
    pgset "$DELAY"
    pgset "ratep $RATEP"
    pgset "dst 192.168.56.10"
    pgset "dst_mac 52:55:00:d1:55:01"
    pgset "udp_dst_min 10000"
    pgset "udp_dst_max 50000"
    pgset "flag IPDST_RND"
    pgset "flows $FLOWS"
    pgset "flowlen 16"
done

PGDEV=/proc/net/pktgen/pgctrl

echo "Running... ctrl^C to stop"
pgset "start"
echo "Done"
