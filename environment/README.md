Basic

To have a SEV environment, we follow procedure from the https://github.com/AMDESE/AMDSEV/tree/snp-latest

Running Guest VM

taskset -pc 44-47 /root/AMDSEV/usr/local/bin/qemu-system-x86_64 -enable-kvm -cpu EPYC-v4 -machine q35 -smp 4,maxcpus=48 -m 2048M,slots=5,maxmem=30G -no-reboot -drive if=pflash,format=raw,unit=0,file=/root/AMDSEV/usr/local/share/qemu/OVMF_CODE.fd,readonly=on -drive if=pflash,format=raw,unit=1,file=/root/AMDSEV/ubuntu.fd -netdev user,id=vmnic,hostfwd=tcp::2222-:22 -device virtio-net-pci,disable-legacy=on,iommu_platform=true,netdev=vmnic,romfile= -netdev tap,id=mynet0,ifname=tap0,script=no,downscript=no -device virtio-net-pci,netdev=mynet0,mac=52:55:00:d1:55:01 -drive file=/root/AMDSEV/ubuntu.qcow2,if=none,id=disk0,format=qcow2 -device virtio-scsi-pci,id=scsi0,disable-legacy=on,iommu_platform=true -device scsi-hd,drive=disk0 -machine memory-encryption=sev0,vmport=off -object sev-snp-guest,id=sev0,cbitpos=51,reduced-phys-bits=1 -monitor pty -monitor unix:monitor,server,nowait -vnc :0 -daemonize

First Time

/root/AMDSEV/usr/local/bin/qemu-system-x86_64 -enable-kvm -cpu EPYC-v4 -machine q35 -smp 4,maxcpus=48 -m 2048M,slots=5,maxmem=30G -no-reboot -drive if=pflash,format=raw,unit=0,file=/root/AMDSEV/usr/local/share/qemu/OVMF_CODE.fd,readonly -drive if=pflash,format=raw,unit=1,file=/root/AMDSEV/ubuntu_encrypted.fd -drive file=/root/AMDSEV/ubuntu-22.04.2-live-server-amd64.iso,media=cdrom -boot d -drive file=/root/AMDSEV/ubuntu_encrypted.qcow2,if=none,id=disk0,format=qcow2 -device virtio-scsi-pci,id=scsi0,disable-legacy=on,iommu_platform=true -device scsi-hd,drive=disk0 -nographic -vnc :1 -monitor pty -monitor unix:monitor,server,nowait

Running Snort

snort --daq afpacket -i enp0s3 --daq-var buffer_size_mb=512 -z 3 -c snort/etc/snort/snort.lua -R sgx-ids/apps/snort3/rules/community_100.rules -A fast
