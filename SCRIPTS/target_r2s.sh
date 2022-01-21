#!/bin/bash
clear

#使用特定的优化
sed -i 's,-mcpu=generic,-mcpu=cortex-a53+crypto,g' include/target.mk
# 配置 IRQ 并默认关闭 eth0 offloading rx/rx
sed -i '/set_interface_core 4 "eth1"/a\\tset_interface_core 1 "ff150000.i2c"' target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity
sed -i '/ff150000.i2c/a\\tset_interface_core 8 "ff160000.i2c"' target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity
wget -P target/linux/rockchip/armv8/base-files/etc/hotplug.d/iface/ https://github.com/QiuSimons/OpenWrt-Add/raw/master/12-disable-rk3328-eth-offloading
# 交换 lan/wan 口
sed -i "s,'eth1' 'eth0','eth0' 'eth1',g" target/linux/rockchip/armv8/base-files/etc/board.d/02_network

chmod -R 755 ./
