<h1 align="center">NanoPi-R2S/R4S/T6-OpenWrt</h1>
<p align="center">
<img src="https://forthebadge.com/images/badges/built-with-love.svg">
<p>
<p align="center">
<img alt="GitHub All Releases" src="https://img.shields.io/github/downloads/msylgj/R2S-R4S-OpenWrt/total?style=for-the-badge">
<img alt="GitHub" src="https://img.shields.io/github/license/msylgj/R2S-R4S-OpenWrt?style=for-the-badge">
<p>
<p align="center">
<img src="https://github.com/msylgj/R2S-R4S-OpenWrt/actions/workflows/Immortalwrt-snapshot.yml/badge.svg">
<img src="https://github.com/msylgj/R2S-R4S-OpenWrt/actions/workflows/Immortalwrt-release.yml/badge.svg">
<p>

<h1 align="center">请勿用于商业用途!!!</h1>

## 当前已知问题:
- 无
## 说明
* ImmortalWrt master branch-SNAPSHOT / ImmortalWrt Release
* Linux-kernel: 6.6.x / 5.15.x
* Fork自ImmortalWrt,个人根据**完全私人**口味进行了一定修改,建议去源库了解更多
    - [immortalwrt](https://github.com/immortalwrt/immortalwrt)
* ipv4: 192.168.2.1
* username: root
* password: 空 / password
* 原汁原味非杂交! 感谢Immortalwrt/R2S Club/R4S Club/天灵/GC/QC等诸多大佬的努力!
* 添加Flow Offload+Full Cone Nat
* 支持scp和sftp
* 无usb-wifi支持
* 原生OP内置升级可用,固件重置可用
* OC-1.6(r2s)/2.2-1.8(r4s)/2.4-1.8(T6)

## 插件清单
- 仅供参考，不同设备和分支插件略有区别，具体查看SEED/config
- app:arpbind
- app:autoreboot
- app:cpufreq
- app:daed
- app:frps
- app:mihomo
- app:ramfree
- app:wechatpush
- app:tencentddns
- app:vlmcsd
- app:wol
- app:zerotier
- theme:argon
- theme:bootstrap

## 升级方法
* 原生OP内置升级,可选保留配置
* reset按钮可用(使用squashfs格式固件)
* 刷写或升级后遇到任何问题，可以尝试ssh进路由器，输入fuck，回车后等待重启，或可解决(使用squashfs格式固件,需要修改prepare_package去掉最后的注释,来自QiuSimons)

## 特别感谢（排名不分先后）

|          [CTCGFW](https://github.com/immortalwrt)           |           [coolsnowwolf](https://github.com/coolsnowwolf)            |              [QiuSimons](https://github.com/QiuSimons)               |              [Quintus](https://github.com/quintus-lab)               |              [mj22226](https://github.com/mj22226)               |
| :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: |
| <img width="120" src="https://avatars.githubusercontent.com/u/53193414"/> | <img width="120" src="https://avatars.githubusercontent.com/u/31687149" /> | <img width="120" src="https://avatars.githubusercontent.com/u/45143996" /> | <img width="120" src="https://avatars.githubusercontent.com/u/31897806" /> | <img width="120" src="https://avatars.githubusercontent.com/u/67804477" /> |
