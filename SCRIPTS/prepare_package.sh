#!/bin/bash
clear

### 基础部分 ###
# 使用 O3 级别的优化
sed -i 's/Os/O3 -funsafe-math-optimizations -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections/g' include/target.mk
# 更新 Feeds
./scripts/feeds update -a
./scripts/feeds install -a

### 必要的 Patches ###
# Patch jsonc
wget -qO- https://github.com/QiuSimons/YAOF/raw/master/PATCH/jsonc/use_json_object_new_int64.patch | patch -p1

### 获取额外的 LuCI 应用、主题和依赖 ###
# MOD Argon
pushd feeds/luci/themes/luci-theme-argon
wget -qO- https://github.com/msylgj/luci-theme-argon/commit/9fe84a8.patch | patch -p1
popd
# MOD TurboACC To Add BBRv2
pushd feeds/luci/applications/luci-app-turboacc
patch -p1 < ../../../../../PATCHES/001-mod-turboacc-switch-bbr-support-to-bbr2.patch
popd
# DNSPod
svn co https://github.com/msylgj/OpenWrt_luci-app/trunk/luci-app-tencentddns feeds/luci/applications/luci-app-tencentddns
ln -sf ../../../feeds/luci/applications/luci-app-tencentddns ./package/feeds/luci/luci-app-tencentddns
# OpenClash
rm -rf feeds/luci/applications/luci-app-openclash
svn co https://github.com/vernesong/OpenClash/branches/dev/luci-app-openclash feeds/luci/applications/luci-app-openclash
# ServerChan
rm -rf feeds/luci/applications/luci-app-serverchan
git clone -b master --depth 1 https://github.com/tty228/luci-app-serverchan.git feeds/luci/applications/luci-app-serverchan
# 翻译及部分功能优化
svn co https://github.com/msylgj/OpenWrt-Add/trunk/addition-trans-zh package/emortal/addition-trans-zh

### 最后的收尾工作 ###
# Lets Fuck
if [ ! -d "package/base-files/files/usr/bin" ]; then
    mkdir package/base-files/files/usr/bin
fi
cp -f ../SCRIPTS/fuck package/base-files/files/usr/bin/fuck
# 定制化配置
sed -i "s/'%D %V %C'/'Built by OPoA($(date +%Y.%m.%d))@%D %V'/g" package/base-files/files/etc/openwrt_release
sed -i "/DISTRIB_REVISION/d" package/base-files/files/etc/openwrt_release
sed -i "/%D/a\ Built by OPoA($(date +%Y.%m.%d))" package/base-files/files/etc/banner
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate
sed -i 's/1608/1800/g' feeds/luci/applications/luci-app-cpufreq/root/etc/uci-defaults/cpufreq
sed -i 's/2016/2208/g' feeds/luci/applications/luci-app-cpufreq/root/etc/uci-defaults/cpufreq
#sed -i 's/1512/1608/g' feeds/luci/applications/luci-app-cpufreq/root/etc/uci-defaults/cpufreq
# 生成默认配置及缓存
rm -rf .config

exit 0
