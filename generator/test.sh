#!/bin/bash

CPUS=32
PKTS="1000"
CLONE_SKB="clone_skb 0"
PKT_SIZE="pkt_size 1024"
COUNT="count 0"
DELAY="delay 0"
ETH="tap0"
RATEP="1000000"

function pgset() {
    local result
    echo $1
    echo $1 > $PGDEV
    result=`cat $PGDEV | fgrep "Result: OK:"`
    if [ "$result" = "" ]; then
        cat $PGDEV | fgrep Result:
    fi
}

for ((processor=0;processor<$CPUS;processor++))
do
    PGDEV=/proc/net/pktgen/kpktgend_$processor
    echo "Removing all devices"
    pgset "rem_device_all"
done

for ((processor=0;processor<$CPUS;processor++))
do
    PGDEV=/proc/net/pktgen/kpktgend_$processor
    echo "Adding $ETH"
    pgset "add_device $ETH@$processor"
    PGDEV=/proc/net/pktgen/$ETH@$processor
    echo "Configuring $PGDEV"
    pgset "$COUNT"
    pgset "flag QUEUE_MAP_CPU"
    pgset "$CLONE_SKB"
    pgset "frags 10"
    pgset "$PKT_SIZE"
    pgset "$DELAY"
    pgset "ratep $RATEP"
    #pgset "burst 10000"
    pgset "dst 1.1.1.1"
    pgset "dst_mac 52:55:00:d1:55:01"
    pgset "udp_dst_min 10000"
    pgset "udp_dst_max 50000"
    pgset "flag IPDST_RND"
    pgset "flows 32000"
    pgset "flowlen 16"
done

PGDEV=/proc/net/pktgen/pgctrl

echo "Running... ctrl^C to stop"
pgset "start"
echo "Done"
