# Kernel size, vmlinux > vmlinuz > zImage > bzImage
# How to build kernel:
# 	make distclean && make x86_64_defconfig && make menuconfig && make -j4
#   The generated kerkel: arch/x86/boot/bzImage

# Default LOOPN is 14, but it is better to set it on the command line
LOOPN := 14

disk:
	qemu-img create -f raw disk.img 1G
	# need to enable bootable flag by input a
	fdisk disk.img
	# map all device partitions to separated loop partition in /dev/mapper/loop<n>p<n>
	# Loop Device is located at /dev/loop<n>
	kpartx -av disk.img
	ls /dev/mapper

mountAndPopulate:
	mkfs -t ext4 /dev/mapper/loop$(LOOPN)p1
	# mount a partition to a directory
	# each partition is arranged as an separated stored device by OS
	mount /dev/mapper/loop$(LOOPN)p1 /mnt/disk
	# Grub installs the boot info in the fist section of the whole device(MBR, GPT)
	# So can not specify the /dev/mapper/loop1p1 for specific partition
	grub-install --boot-directory=/mnt/disk/boot/ /dev/loop$(LOOPN)
	cp -a /home/scl/learning/mbr/rootfs/* /mnt/disk/
	umount /mnt/disk
	kpartx -d disk.img

boot:
	#qemu-system-x86_64 disk.img -kernel ../qemu_test/build/vmlinuz  -serial stdio -append "root=/dev/sda1 console=ttyS0,115200"
	-qemu-system-x86_64 disk.img -kernel bzImage  -serial stdio -append "root=/dev/sda1 console=ttyS0,115200"


distclean:
	-rm -rf disk.img
	-umount /mnt/disk
	-kpartx -d dist.img



