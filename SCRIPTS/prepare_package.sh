#!/bin/bash
clear

### 基础部分 ###
# 使用 O3 级别的优化
sed -i 's/Os/O3/g' include/target.mk
# 更新 Feeds
./scripts/feeds update -a
./scripts/feeds install -a

### 必要的 Patches ###
# Patch jsonc
wget -q https://github.com/QiuSimons/R2S-R4S-X86-OpenWrt/raw/master/PATCH/jsonc/use_json_object_new_int64.patch
patch -p1 < ./use_json_object_new_int64.patch
# fix firewall flock
patch -p1 < ../PATCHES/001-fix-firewall-flock.patch
# patch pdnsd-alt
mkdir -p feeds/packages/net/pdnsd-alt/patches
cp -f ../PATCHES/002-fix-pdnsd-alt-build-error-within-kernel5.14.patch feeds/packages/net/pdnsd-alt/patches/

### 获取额外的Packages ###
# GCC11
rm -rf ./package/libs/elfutils
svn co https://github.com/neheb/openwrt/branches/elf/package/libs/elfutils package/libs/elfutils

### 获取额外的 LuCI 应用、主题和依赖 ###
# MOD Argon
pushd feeds/luci/themes/luci-theme-argon
wget -qO - https://github.com/msylgj/luci-theme-argon/commit/0197576.patch | patch -p1
popd
# DNSPod
svn co https://github.com/msylgj/OpenWrt_luci-app/trunk/luci-app-tencentddns package/emortal/luci-app-tencentddns
# SSR Plus: add DNSProxy support
rm -rf ./feeds/luci/applications/luci-app-ssr-plus
svn co https://github.com/msylgj/helloworld/branches/dnsproxy-edns/luci-app-ssr-plus feeds/luci/applications/luci-app-ssr-plus
# 翻译及部分功能优化
svn co https://github.com/QiuSimons/OpenWrt-Add/trunk/addition-trans-zh package/emortal/addition-trans-zh
cp -f ../SCRIPTS/zzz-default-settings package/emortal/addition-trans-zh/files/zzz-default-settings

### 最后的收尾工作 ###
# Lets Fuck
mkdir package/base-files/files/usr/bin
cp -f ../SCRIPTS/fuck package/base-files/files/usr/bin/fuck
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
