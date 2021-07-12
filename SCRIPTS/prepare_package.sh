#!/bin/bash
clear

### 基础部分 ###
# Maaaagiiiiiiiic Victoria's Secret!
rm -f ./feeds.conf.default
rm -f ./include/target.mk
rm -f ./include/version.mk
rm -f ./include/download.mk
rm -f ./scripts/download.pl
wget https://github.com/immortalwrt/immortalwrt/raw/master/feeds.conf.default
wget -P include/ https://github.com/immortalwrt/immortalwrt/raw/master/include/target.mk
wget -P include/ https://github.com/immortalwrt/immortalwrt/raw/master/include/version.mk
wget -P include/ https://github.com/immortalwrt/immortalwrt/raw/master/include/download.mk
wget -P scripts/ https://github.com/immortalwrt/immortalwrt/raw/master/scripts/download.pl
# 使用 O3 级别的优化
sed -i 's/Os/O3/g' include/target.mk
# 更新 Feeds
./scripts/feeds update -a
./scripts/feeds install -a

### 必要的 Patches ###
# Try to backport patches
cp -rf ../patches-5.13 target/linux/rockchip/patches-5.13
# hw_random support
svn co https://github.com/immortalwrt/immortalwrt/branches/master/target/linux/rockchip/files/drivers/char/hw_random target/linux/rockchip/files/drivers/char/hw_random
# Patch arm64 型号名称
wget -P target/linux/generic/hack-5.13 https://github.com/immortalwrt/immortalwrt/raw/master/target/linux/generic/hack-5.10/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch
# Patch jsonc
wget -q https://github.com/QiuSimons/R2S-R4S-X86-OpenWrt/raw/master/PATCH/new/package/use_json_object_new_int64.patch
patch -p1 < ./use_json_object_new_int64.patch
# firewall: add fullconenat patch
wget -P package/network/config/firewall/patches https://github.com/immortalwrt/immortalwrt/raw/master/package/network/config/firewall/patches/fullconenat.patch
# fix firewall flock
patch -p1 < ../SCRIPTS/fix_firewall_flock.patch
# patch dnsmasq
wget -P package/network/services/dnsmasq/patches https://github.com/immortalwrt/immortalwrt/raw/master/package/network/config/firewall/patches/910-mini-ttl.patch
wget -P package/network/services/dnsmasq/patches https://github.com/immortalwrt/immortalwrt/raw/master/package/network/config/firewall/patches/911-dnsmasq-filter-aaaa.patch

### 获取额外的Packages ###
# UPX 可执行软件压缩
sed -i '/patchelf pkgconf/i\tools-y += ucl upx' ./tools/Makefile
sed -i '\/autoconf\/compile :=/i\$(curdir)/upx/compile := $(curdir)/ucl/compile' ./tools/Makefile
svn co https://github.com/immortalwrt/immortalwrt/branches/master/tools/upx tools/upx
svn co https://github.com/immortalwrt/immortalwrt/branches/master/tools/ucl tools/ucl
# mbedtls
rm -rf ./package/libs/mbedtls
svn co https://github.com/immortalwrt/immortalwrt/branches/master/package/libs/mbedtls package/libs/mbedtls
# fullconenat
svn co https://github.com/immortalwrt/immortalwrt/branches/master/package/kernel/fullconenat package/kernel/fullconenat
# exfat
svn co https://github.com/immortalwrt/immortalwrt/branches/master/package/kernel/exfat package/kernel/exfat
# emortal
svn co https://github.com/immortalwrt/immortalwrt/branches/master/package/emortal package/emortal

### 获取额外的 LuCI 应用、主题和依赖 ###
# MOD Argon
pushd feeds/luci/themes/luci-theme-argon
wget -qO - https://github.com/msylgj/luci-theme-argon/commit/0197576.patch | patch -p1
popd
# MAC 地址与 IP 绑定
rm -rf ./feeds/luci/applications/luci-app-arpbind
svn co https://github.com/msylgj/OpenWrt_luci-app/trunk/luci-app-arpbind feeds/luci/applications/luci-app-arpbind
# DNSPod
svn co https://github.com/msylgj/OpenWrt_luci-app/trunk/luci-app-tencentddns package/emortal/luci-app-tencentddns
# ServerChan 微信推送
rm -rf ./feeds/luci/applications/luci-app-serverchan
svn co https://github.com/msylgj/OpenWrt_luci-app/trunk/luci-app-serverchan feeds/luci/applications/luci-app-serverchan
# SSR Plus: add DNSProxy support
rm -rf ./feeds/luci/applications/luci-app-ssr-plus
svn co https://github.com/msylgj/helloworld/branches/dnsproxy-edns/luci-app-ssr-plus feeds/luci/applications/luci-app-ssr-plus
# 翻译及部分功能优化
svn co https://github.com/QiuSimons/OpenWrt-Add/trunk/addition-trans-zh package/emortal/addition-trans-zh
cp -f ../SCRIPTS/zzz-default-settings package/emortal/addition-trans-zh/files/zzz-default-settings
# 临时干掉pdnsd-alt 编译报错
sed -i 's/+pdnsd-alt //g' feeds/luci/applications/luci-app-ssr-plus/Makefile
sed -i 's/+pdnsd-alt//g' feeds/luci/applications/luci-app-turboacc/Makefile

### 最后的收尾工作 ###
# Lets Fuck
mkdir package/base-files/files/usr/bin
cp -f ../SCRIPTS/fuck package/base-files/files/usr/bin/fuck
# 最大连接数及nf_conntrack_helper
sed -i 's/16384/65535/g' package/kernel/linux/files/sysctl-nf-conntrack.conf
echo "net.netfilter.nf_conntrack_helper = 1" >> ./package/kernel/linux/files/sysctl-nf-conntrack.conf
# 定制化配置
sed -i "s/'%D %V %C'/'Built by OPoA($(date +%Y.%m.%d))@%D %V'/g" package/base-files/files/etc/openwrt_release
sed -i "/DISTRIB_REVISION/d" package/base-files/files/etc/openwrt_release
sed -i "/%D/a\ Built by OPoA($(date +%Y.%m.%d))" package/base-files/files/etc/banner
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate
sed -i 's/+kmod-fast-classifier //g' package/emortal/addition-trans-zh/Makefile
pushd feeds/luci/applications/luci-app-ssr-plus
sed -i 's,ispip.clang.cn/all_cn,cdn.jsdelivr.net/gh/QiuSimons/Chnroute@master/dist/chnroute/chnroute,' root/etc/init.d/shadowsocksr
sed -i 's,YW5vbnltb3Vz/domain-list-community/release/gfwlist.txt,Loyalsoldier/v2ray-rules-dat/release/gfw.txt,' root/etc/init.d/shadowsocksr
sed -i '/Clang.CN.CIDR/a\o:value("https://cdn.jsdelivr.net/gh/QiuSimons/Chnroute@master/dist/chnroute/chnroute.txt", translate("QiuSimons/Chnroute"))' luasrc/model/cbi/shadowsocksr/advanced.lua
wget -qO- https://github.com/1715173329/ssrplus-routing-rules/raw/master/direct/microsoft.txt | cat > root/etc/ssrplus/white.list
popd
sed -i 's/1608/1800/g' feeds/luci/applications/luci-app-cpufreq/root/etc/uci-defaults/cpufreq
sed -i 's/2016/2208/g' feeds/luci/applications/luci-app-cpufreq/root/etc/uci-defaults/cpufreq
#sed -i 's/1512/1608/g' feeds/luci/applications/luci-app-cpufreq/root/etc/uci-defaults/cpufreq
# 生成默认配置及缓存
rm -rf .config

exit 0
