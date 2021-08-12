#!/bin/bash
clear

#使用特定的优化
sed -i 's,-mcpu=generic,-mcpu=cortex-a72.cortex-a53+crypto,g' include/target.mk
#IRQ 调优
sed -i '/set_interface_core 20 "eth1"/a\set_interface_core 8 "ff3c0000" "ff3c0000.i2c"' target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity
sed -i '/set_interface_core 20 "eth1"/a\ethtool -C eth0 rx-usecs 1000 rx-frames 25 tx-usecs 100 tx-frames 25' target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity

# CacULE
sed -i '/CONFIG_NR_CPUS/d' ./target/linux/rockchip/armv8/config-5.14
echo '
CONFIG_NR_CPUS=6
CONFIG_CACULE_SCHED=y
CONFIG_CACULE_RDB=y
CONFIG_RDB_INTERVAL=19
' >> ./target/linux/rockchip/armv8/config-5.14

# UKSM
echo '
CONFIG_KSM=y
CONFIG_UKSM=y
' >> ./target/linux/rockchip/armv8/config-5.14

chmod -R 755 ./
