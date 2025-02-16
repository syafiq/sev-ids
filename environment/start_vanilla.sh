#!/bin/bash

taskset -c 41-47 sh -c "/root/AMDSEV/usr/local/bin/qemu-system-x86_64 -enable-kvm -cpu EPYC-v4 -machine q35 -smp 8,maxcpus=48 -m 16384M,slots=8,maxmem=30G -no-reboot -drive if=pflash,format=raw,unit=0,file=/root/AMDSEV/usr/local/share/qemu/OVMF_CODE.fd,readonly=on -drive if=pflash,format=raw,unit=1,file=/root/AMDSEV/ubuntu_encrypted.fd -netdev user,id=vmnic,hostfwd=tcp::2222-:22 -device virtio-net-pci,disable-legacy=on,iommu_platform=true,netdev=vmnic,romfile= -netdev tap,id=mynet0,ifname=tap0,script=no,downscript=no -device virtio-net-pci,netdev=mynet0,mac=52:55:00:d1:55:02 -drive file=/root/AMDSEV/ubuntu_encrypted.qcow2,if=none,id=disk0,format=qcow2 -device virtio-scsi-pci,id=scsi0,disable-legacy=on,iommu_platform=true -device scsi-hd,drive=disk0 -monitor pty -monitor unix:monitor,server,nowait -vnc :0 -daemonize"
sudo ip link set tap0 up
sudo ip addr add 192.168.56.56/24 dev tap0
