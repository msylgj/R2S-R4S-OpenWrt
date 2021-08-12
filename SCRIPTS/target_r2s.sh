#!/bin/bash
clear

#使用特定的优化
sed -i 's,-mcpu=generic,-mcpu=cortex-a53+crypto,g' include/target.mk
# 配置 IRQ 并默认关闭 eth0 offloading rx/rx
sed -i '/set_interface_core 4 "eth1"/a\set_interface_core 8 "ff160000" "ff160000.i2c"' target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity
sed -i '/set_interface_core 4 "eth1"/a\set_interface_core 1 "ff150000" "ff150000.i2c"' target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity
sed -i '/set_interface_core 8/a\ethtool -K eth0 rx off tx off && logger -t disable-offloading "disabed rk3328 ethernet tcp/udp offloading tx/rx"' target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity
# 交换 lan/wan 口
sed -i "s,'eth1' 'eth0','eth0' 'eth1',g" target/linux/rockchip/armv8/base-files/etc/board.d/02_network

# CacULE
sed -i '/CONFIG_NR_CPUS/d' ./target/linux/rockchip/armv8/config-5.14
echo '
CONFIG_NR_CPUS=4
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
