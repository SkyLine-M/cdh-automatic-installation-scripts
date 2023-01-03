#!/bin/bash

echo "===================================开始安装docker====================================================="
# 如果以前安装过Docker，那么为了保证环境的一致性，还是先卸载了再安装比较好
echo "开始卸载旧docker"
yum -y remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine docker-selinux docker-engine-selinux
rpm -qa |grep docker*
# 卸载docker-ce
yum -y remove docker-ce
# 清理docker-ce数据
rm -rf /var/lib/docker

echo "安装依赖包"
# yum-utils提供yum-config-manager和utility工具
# lvm2和device-mapper-persistent-data提供devicemapper的存储驱动
yum -y install yum-utils lvm2 device-mapper-persistent-data -y

echo "配置stable库"
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

echo "禁用edge和test库"
# 如果启用edge和test库，yum安装时会安装最新版的docker，一般为test测试版，如果要安装最新的稳定版需要禁用该选项
yum-config-manager --disable docker-ce-edge docker-ce-test
# yum-config-manager --enable docker-ce-edge docker-ce-test

echo "开始安装docker"
# docker-ce是最新版docker，如果用yum -y install docker ，那么只能安装到1.13版本，很多特性是没法使用的
yum -y install docker-ce
# 升级：yum -y upgrade
# 指定版本：yum -y install docker-ce-18.06.1.ce-3.el7

echo "设置开机启动"
systemctl enable docker

echo "自定义网桥"
# 是因为docker的网桥网段有可能与主机冲突，我就是碰到了这个问题
mkdir -p /etc/docker
echo '{
  "debug" : true,
  "default-address-pools" : [
    {
      "base" : "172.31.0.0/16",
      "size" : 24
    }
  ]
}' > /etc/docker/daemon.json

echo "重启daemon服务"
systemctl daemon-reload

echo "重启docker"
systemctl restart docker

echo "docker安装成功，版本信息如下"
docker -v
echo "===================================docker安装完成====================================================="
echo -e '\n\n\n\n'
echo "===================================开始安装docker-compose====================================================="
echo "开始卸载旧docker-compose"
rm /usr/local/bin/docker-compose

echo "开始安装docker-compose"
curl -L https://get.daocloud.io/docker/compose/releases/download/1.25.5/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose

echo "脚本授予执行权限"
chmod +x /usr/local/bin/docker-compose

echo "bash命令补全"
curl -L https://raw.githubusercontent.com/docker/compose/1.25.5/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose

echo "docker-compose安装成功，版本信息如下"
docker-compose -v
echo "===================================docker-compose安装完成====================================================="