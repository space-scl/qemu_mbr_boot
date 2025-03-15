# Kernel size, vmlinux > vmlinuz > zImage > bzImage
# How to build kernel:
# 	make distclean && make x86_64_defconfig && make menuconfig && make -j4
#   The generated kerkel: arch/x86/boot/bzImage

# Default LOOPN is 14, but it is better to set it on the command line
################################
LOOPN := 14
#
#
#disk:
#	qemu-img create -f raw disk.img 1G
#	# need to enable bootable flag by input a
#	fdisk disk.img
#	# map all device partitions to separated loop partition in /dev/mapper/loop<n>p<n>
#	# Loop Device is located at /dev/loop<n>
#	kpartx -av disk.img
#	ls /dev/mapper
#
#mountAndPopulate:
#	mkfs -t ext4 /dev/mapper/loop$(LOOPN)p1
#	# mount a partition to a directory
#	# each partition is arranged as an separated stored device by OS
#	mount /dev/mapper/loop$(LOOPN)p1 /mnt/disk
#	# Grub installs the boot info in the fist section of the whole device(MBR, GPT)
#	# So can not specify the /dev/mapper/loop1p1 for specific partition
#	grub-install --boot-directory=/mnt/disk/boot/ /dev/loop$(LOOPN)
#	cp -a /home/scl/learning/mbr/rootfs/* /mnt/disk/
#	umount /mnt/disk
#	kpartx -d disk.img
#
#boot:
#	#qemu-system-x86_64 disk.img -kernel ../qemu_test/build/vmlinuz  -serial stdio -append "root=/dev/sda1 console=ttyS0,115200"
#	-qemu-system-x86_64 disk.img -kernel bzImage  -serial stdio -append "root=/dev/sda1 console=ttyS0,115200"
#
#
#distclean:
#	-rm -rf disk.img
#	-umount /mnt/disk
#	-kpartx -d dist.img
################################

# 工具链配置（根据你的交叉编译工具链调整）
CROSS_COMPILE = arm-linux-gnueabi-
KERNEL_IMAGE = arch/arm/boot/zImage
DTB_FILE = arch/arm/boot/dts/arm/vexpress-v2p-ca9.dtb
UBOOT_IMAGE = u-boot.bin

# 磁盘镜像配置
DISK_IMAGE = arm-disk.img
ROOTFS_DIR = rootfs-arm/

.PHONY: all clean disk mountAndPopulate boot

all: disk mountAndPopulate

# 创建磁盘镜像并分区
disk:
	qemu-img create -f raw $(DISK_IMAGE) 1G
	fdisk $(DISK_IMAGE)  # 创建单个分区
	kpartx -av $(DISK_IMAGE)
	sleep 1  # 等待设备节点生成
	ls /dev/mapper

# 挂载并填充 rootfs
mountAndPopulate:
	mkdir -p /mnt/arm-disk
	mkfs -t ext4 /dev/mapper/loop$(LOOPN)p1
#	# mount a partition to a directory
#	# each partition is arranged as an separated stored device by OS
	mount /dev/mapper/loop$(LOOPN)p1 /mnt/arm-disk

	# 安装 U-Boot 到磁盘镜像
	sudo dd if=$(UBOOT_IMAGE) of=$(DISK_IMAGE) conv=notrunc bs=512 seek=1

	# 复制 rootfs 内容
	#cd $(ROOTFS_DIR) && tar -xvf rootfs.tar
	cp -a $(ROOTFS_DIR)/* /mnt/arm-disk/
	sudo umount /mnt/arm-disk
	kpartx -d $(DISK_IMAGE)


# 启动 QEMU（ARM vexpress 平台）
boot:
	qemu-system-arm \
		-M vexpress-a9 \
		-m 512M \
		-kernel $(KERNEL_IMAGE) \
		-dtb $(DTB_FILE) \
		-drive file=$(DISK_IMAGE),if=sd,format=raw \
		-append "root=/dev/mmcblk0p1 rw console=ttyAMA0" \
		-nographic

#	-qemu-system-x86_64 disk.img -kernel bzImage  -serial stdio -append "root=/dev/sda1 console=ttyS0,115200"
clean:
	-rm -f $(DISK_IMAGE)
	-sudo rm -rf /mnt/arm-disk

