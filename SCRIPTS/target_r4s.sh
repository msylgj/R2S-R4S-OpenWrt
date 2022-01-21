#!/bin/bash
clear

#使用特定的优化
sed -i 's,-mcpu=generic,-mcpu=cortex-a72.cortex-a53+crypto,g' include/target.mk
#IRQ 调优
sed -i '/set_interface_core 20 "eth1"/a\\tset_interface_core 2 "ff3c0000.i2c"' target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity

chmod -R 755 ./
