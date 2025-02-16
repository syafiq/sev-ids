Basic

Kernel Setup 
Host
sysctl net.ipv4.ip_local_port_range="10000 61000"
sysctl net.ipv4.tcp_fin_timeout=10
sysctl net.ipv4.tcp_tw_reuse=1 
ulimit -n 100000

VM
sysctl net.core.somaxconn=65536
ifconfig enp0s3 txqueuelen 5000
sysctl net.core.netdev_max_backlog=4000
sysctl net.ipv4.tcp_max_syn_backlog=4096
ulimit -n 100000

To have a SEV environment, we follow procedure from the https://github.com/AMDESE/AMDSEV/tree/snp-latest

Running Guest VM

Kernel 5.19
taskset -pc 41-47 /root/AMDSEV/usr/local/bin/qemu-system-x86_64 -enable-kvm -cpu EPYC-v4 -machine q35 -smp 4,maxcpus=48 -m 2048M,slots=5,maxmem=30G -no-reboot -drive if=pflash,format=raw,unit=0,file=/root/AMDSEV/usr/local/share/qemu/OVMF_CODE.fd,readonly=on -drive if=pflash,format=raw,unit=1,file=/root/AMDSEV/ubuntu.fd -netdev user,id=vmnic,hostfwd=tcp::2222-:22 -device virtio-net-pci,disable-legacy=on,iommu_platform=true,netdev=vmnic,romfile= -netdev tap,id=mynet0,ifname=tap0,script=no,downscript=no -device virtio-net-pci,netdev=mynet0,mac=52:55:00:d1:55:01 -drive file=/root/AMDSEV/ubuntu.qcow2,if=none,id=disk0,format=qcow2 -device virtio-scsi-pci,id=scsi0,disable-legacy=on,iommu_platform=true -device scsi-hd,drive=disk0 -machine memory-encryption=sev0,vmport=off -object sev-snp-guest,id=sev0,cbitpos=51,reduced-phys-bits=1 -monitor pty -monitor unix:monitor,server,nowait -vnc :0 -daemonize

Kernel 6.1
snp vm
taskset -c 41-47 sh -c "/root/AMDSEV/usr/local/bin/qemu-system-x86_64 -enable-kvm -cpu EPYC-v4 -machine q35 -smp 8,maxcpus=48 -m 16384M,slots=8,maxmem=30G -no-reboot -drive if=pflash,format=raw,unit=0,file=/root/AMDSEV/usr/local/share/qemu/OVMF_CODE.fd,readonly=on -drive if=pflash,format=raw,unit=1,file=/root/AMDSEV/ubuntu_encrypted.fd -netdev user,id=vmnic,hostfwd=tcp::2222-:22 -device virtio-net-pci,disable-legacy=on,iommu_platform=true,netdev=vmnic,romfile= -netdev tap,id=mynet0,ifname=tap0,script=no,downscript=no -device virtio-net-pci,netdev=mynet0,mac=52:55:00:d1:55:02 -drive file=/root/AMDSEV/ubuntu_encrypted.qcow2,if=none,id=disk0,format=qcow2 -device virtio-scsi-pci,id=scsi0,disable-legacy=on,iommu_platform=true -device scsi-hd,drive=disk0 -machine memory-encryption=sev0,vmport=off -object memory-backend-memfd-private,id=ram1,size=16384M,share=true -object sev-snp-guest,id=sev0,cbitpos=51,reduced-phys-bits=1,discard=none -machine memory-backend=ram1,kvm-type=protected -monitor pty -monitor unix:monitor,server,nowait -vnc :0 -daemonize"

vanilla vm
taskset -c 41-47 sh -c "/root/AMDSEV/usr/local/bin/qemu-system-x86_64 -enable-kvm -cpu EPYC-v4 -machine q35 -smp 8,maxcpus=48 -m 16384M,slots=8,maxmem=30G -no-reboot -drive if=pflash,format=raw,unit=0,file=/root/AMDSEV/usr/local/share/qemu/OVMF_CODE.fd,readonly=on -drive if=pflash,format=raw,unit=1,file=/root/AMDSEV/ubuntu_encrypted.fd -netdev user,id=vmnic,hostfwd=tcp::2222-:22 -device virtio-net-pci,disable-legacy=on,iommu_platform=true,netdev=vmnic,romfile= -netdev tap,id=mynet0,ifname=tap0,script=no,downscript=no -device virtio-net-pci,netdev=mynet0,mac=52:55:00:d1:55:02 -drive file=/root/AMDSEV/ubuntu_encrypted.qcow2,if=none,id=disk0,format=qcow2 -device virtio-scsi-pci,id=scsi0,disable-legacy=on,iommu_platform=true -device scsi-hd,drive=disk0 -monitor pty -monitor unix:monitor,server,nowait -vnc :0 -daemonize"

First Time Installation

/root/AMDSEV/usr/local/bin/qemu-system-x86_64 -enable-kvm -cpu EPYC-v4 -machine q35 -smp 4,maxcpus=48 -m 2048M,slots=5,maxmem=30G -no-reboot -drive if=pflash,format=raw,unit=0,file=/root/AMDSEV/usr/local/share/qemu/OVMF_CODE.fd,readonly -drive if=pflash,format=raw,unit=1,file=/root/AMDSEV/ubuntu_encrypted.fd -drive file=/root/AMDSEV/ubuntu-22.04.2-live-server-amd64.iso,media=cdrom -boot d -drive file=/root/AMDSEV/ubuntu_encrypted.qcow2,if=none,id=disk0,format=qcow2 -device virtio-scsi-pci,id=scsi0,disable-legacy=on,iommu_platform=true -device scsi-hd,drive=disk0 -nographic -vnc :1 -monitor pty -monitor unix:monitor,server,nowait

Running Snort

snort --daq afpacket -i enp0s3 --daq-var buffer_size_mb=512 -z 3 -c snort/etc/snort/snort.lua -R sgx-ids/apps/snort3/rules/community_100.rules -A fast
