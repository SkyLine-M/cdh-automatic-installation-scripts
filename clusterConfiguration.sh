#!/bin/bash
echo "开始脚本字符初始化"
sh ./scriptCharacterInitialization/scriptCharacterInitialization.sh
echo "1.开始配置免密登录"
sh ./batchFreePasswordLogin/batchSSHFreePasswordLogin.sh
echo "2.开始配置hostname"
sh ./batchChangeHostName/batchChangeHostname.sh
echo "3.开始配置域名映射"
sh ./batchChangeHosts/batchChangeHosts.sh
echo "4.开始关闭防火墙和Selinux"
sh ./batchCloseFirewallAndSelinux/batchCloseFirewallAndSelinux.sh
echo "5.开始设置时区"
sh ./batchSetTimeZone/batchSetTimeZone.sh
echo "6.开始配置时钟同步"
sh ./batchClockSynchronization/batchClockSynchronization.sh
echo "7.开始禁用透明大页"
sh ./batchCloseTransparentHugePage/batchCloseTransparentHugePage.sh
echo "8.开始修改Linux swappiness参数"
sh ./batchChangeSwappiness/batchChangeSwappiness.sh
echo "9.开始搭建本地yum源"
sh ./batchInstallLocalYumRepository/batchInstallLocalYumRepository.sh
echo "10.开始安装docker"
sh ./installDockerAndCompose/installDockerAndCompose.sh
echo "11.开始安装mysql"
sh ./installMysql/installMysql.sh
echo "12.开始安装JDK"
sh ./batchInstallJDK/batchInstallJDK.sh
echo "13.开始安装CM-Agent"
sh ./installCM/batchInstallCMAgent.sh
echo "14.开始安装CM-Server"
sh ./installCM/installCMServer.sh