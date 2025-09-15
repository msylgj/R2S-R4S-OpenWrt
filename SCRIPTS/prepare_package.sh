#!/bin/bash
clear

### 基础部分 ###
# 使用 O2 级别的优化
sed -i 's/Os/O2/g' include/target.mk
# 更新 Feeds
./scripts/feeds update -a
./scripts/feeds install -a

### 必要的 Patches ###
# 替换原有的 luci-app-dae 和 dae 使用dae-next from CA
git clone -b next --depth 1 https://github.com/QiuSimons/luci-app-dae.git dae-next
rm -rf feeds/luci/applications/luci-app-dae
rm -rf feeds/packages/net/dae
cp -rf dae-next/luci-app-dae feeds/luci/applications/luci-app-daed
cp -rf dae-next/dae feeds/packages/net/dae
rm -rf dae-next

### 获取额外的 LuCI 应用、主题 ###
# Nikki with SmartGroup
git clone -b main --depth 1 https://github.com/msylgj/OpenWrt-nikki.git nikki
cp -rf nikki/luci-app-nikki feeds/luci/applications/luci-app-nikki
cp -rf nikki/nikki feeds/packages/net/nikki
ln -sf ../../../feeds/luci/applications/luci-app-nikki ./package/feeds/luci/luci-app-nikki
ln -sf ../../../feeds/packages/net/nikki ./package/feeds/packages/nikki
rm -rf nikki

# OpenWrt-Add start
git clone -b master --depth 1 https://github.com/QiuSimons/OpenWrt-Add.git OpenWrt-Add
# Add luci-app-bandix based on ebpf
cp -rf OpenWrt-Add/luci-app-bandix/luci-app-bandix feeds/luci/applications/luci-app-bandix
cp -rf OpenWrt-Add/openwrt-bandix/openwrt-bandix feeds/packages/net/openwrt-bandix
ln -sf ../../../feeds/luci/applications/luci-app-bandix ./package/feeds/luci/luci-app-bandix
ln -sf ../../../feeds/packages/net/openwrt-bandix ./package/feeds/packages/openwrt-bandix

# Add luci-app-einat based on ebpf (fullcone nat)
cp -rf OpenWrt-Add/luci-app-einat feeds/luci/applications/luci-app-einat
cp -rf OpenWrt-Add/openwrt-einat-ebpf feeds/packages/net/openwrt-einat-ebpf
ln -sf ../../../feeds/luci/applications/luci-app-einat ./package/feeds/luci/luci-app-einat
ln -sf ../../../feeds/packages/net/openwrt-einat-ebpf ./package/feeds/packages/openwrt-einat-ebpf
rm -rf pacakge/network/config/firewall4/patches/001-firewall4-add-support-for-fullcone-nat.patch

rm -rf OpenWrt-Add
# OpenWrt-Add end

# MOD Argon
rm -rf feeds/luci/themes/luci-theme-argon
git clone -b randomPic --depth 1 https://github.com/msylgj/luci-theme-argon.git feeds/luci/themes/luci-theme-argon
# WeChatPush
rm -rf feeds/luci/applications/luci-app-wechatpush
git clone -b master --depth 1 https://github.com/tty228/luci-app-wechatpush.git feeds/luci/applications/luci-app-wechatpush
# geodata
rm -rf feeds/packages/net/v2ray-geodata
git clone -b main --depth 1 https://github.com/JohnsonRan/packages_net_v2ray-geodata.git feeds/packages/net/v2ray-geodata
# 更换 Nodejs 版本
rm -rf feeds/packages/lang/node
git clone https://github.com/sbwml/feeds_packages_lang_node-prebuilt feeds/packages/lang/node

### 最后的收尾工作 ###
# Lets Fuck
if [ ! -d "package/base-files/files/usr/bin" ]; then
    mkdir package/base-files/files/usr/bin
fi
cp -f ../SCRIPTS/fuck package/base-files/files/usr/bin/fuck
# 定制化配置
sed -i "s/%D %V %C/Built by OPoA($(date +%Y.%m.%d))@%D %V %C/g" package/base-files/files/usr/lib/os-release
sed -i "/%D/a\ Built by OPoA($(date +%Y.%m.%d))" package/base-files/files/etc/banner
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate
sed -i 's/1608/1800/g' package/emortal/cpufreq/files/cpufreq.uci
sed -i 's/2016/2208/g' package/emortal/cpufreq/files/cpufreq.uci
sed -i 's/1512/1608/g' package/emortal/cpufreq/files/cpufreq.uci
# 生成默认配置及缓存
rm -rf .config

# 清理可能因patch存在的冲突文件
find ./ -name *.orig | xargs rm -rf
find ./ -name *.rej | xargs rm -rf

exit 0
