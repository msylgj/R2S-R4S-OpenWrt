#!/bin/bash

#使用特定的优化
sed -i 's,-mcpu=generic,-mcpu=cortex-a53+crypto,g' include/target.mk
# 交换 lan/wan 口
sed -i "s,'eth1' 'eth0','eth0' 'eth1',g" target/linux/rockchip/armv8/base-files/etc/board.d/02_network
