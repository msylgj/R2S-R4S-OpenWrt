#!/bin/bash
clear

# 更换超频  2.2/1.8 GHz 电压表, 调高温度墙
rm -rf ./target/linux/rockchip/patches-5.4/992-rockchip-rk3399-overclock-to-2.2-1.8-GHz-for-NanoPi4.patch
pushd target/linux/rockchip/patches-5.4/
wget -O 992-rockchip-rk3399-overclock-to-2.2-1.8-GHz-for-NanoPi4.patch https://github.com/QiuSimons/R2S-R4S-X86-OpenWrt/raw/master/PATCH/target_r4s/991-rockchip-rk3399-overclock-to-2.2-1.8-GHz-for-NanoPi4.patch
wget https://github.com/QiuSimons/R2S-R4S-X86-OpenWrt/raw/master/PATCH/target_r4s/213-RK3399-set-critical-CPU-temperature-for-thermal-throttling.patch
popd

# 使用特定的优化
sed -i 's,-mcpu=generic,-march=armv8-a+crypto+crc -mabi=lp64,g' include/target.mk

# 测试性功能
sed -i '/CRYPTO_DEV_ROCKCHIP/d' ./target/linux/rockchip/armv8/config-5.4
echo '
CONFIG_CRYPTO_DEV_ROCKCHIP=y
' >> ./target/linux/rockchip/armv8/config-5.4

# IRQ 调优
sed -i '/set_interface_core 20 "eth1"/a\set_interface_core 8 "ff3c0000" "ff3c0000.i2c"' target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity
sed -i '/set_interface_core 20 "eth1"/a\ethtool -C eth0 rx-usecs 1000 rx-frames 25 tx-usecs 100 tx-frames 25' target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity

# 内核加解密模块
echo '
CONFIG_ARM64_CRYPTO=y
CONFIG_CRYPTO_SHA256_ARM64=y
CONFIG_CRYPTO_SHA512_ARM64=y
CONFIG_CRYPTO_SHA1_ARM64_CE=y
CONFIG_CRYPTO_SHA2_ARM64_CE=y
# CONFIG_CRYPTO_SHA512_ARM64_CE is not set
CONFIG_CRYPTO_SHA3_ARM64=y
CONFIG_CRYPTO_SM3_ARM64_CE=y
CONFIG_CRYPTO_SM4_ARM64_CE=y
CONFIG_CRYPTO_GHASH_ARM64_CE=y
# CONFIG_CRYPTO_CRCT10DIF_ARM64_CE is not set
CONFIG_CRYPTO_AES_ARM64=y
CONFIG_CRYPTO_AES_ARM64_CE=y
CONFIG_CRYPTO_AES_ARM64_CE_CCM=y
CONFIG_CRYPTO_AES_ARM64_CE_BLK=y
CONFIG_CRYPTO_AES_ARM64_NEON_BLK=y
CONFIG_CRYPTO_CHACHA20_NEON=y
CONFIG_CRYPTO_POLY1305_NEON=y
CONFIG_CRYPTO_NHPOLY1305_NEON=y
CONFIG_CRYPTO_AES_ARM64_BS=y
' >> ./target/linux/rockchip/armv8/config-5.4

#Vermagic
latest_version="$(curl -s https://github.com/openwrt/openwrt/releases |grep -Eo "v[0-9\.]+\-*r*c*[0-9]*.tar.gz" |sed -n '/21/p' |sed -n 1p |sed 's/v//g' |sed 's/.tar.gz//g')"
wget https://downloads.openwrt.org/releases/${latest_version}/targets/rockchip/armv8/packages/Packages.gz
zgrep -m 1 "Depends: kernel (=.*)$" Packages.gz | sed -e 's/.*-\(.*\))/\1/' > .vermagic
sed -i -e 's/^\(.\).*vermagic$/\1cp $(TOPDIR)\/.vermagic $(LINUX_DIR)\/.vermagic/' include/kernel-defaults.mk

chmod -R 755 ./

#exit 0