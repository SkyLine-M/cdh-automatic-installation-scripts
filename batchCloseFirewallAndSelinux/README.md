## 本脚本用于关闭防火墙和Selinux

1. 编写好../conf/hostConf文件

2. 在集群中某一台机器上执行下面脚本即可。
```shell
sh batchCloseFirewallAndSelinux.sh
```

## 关闭原因

> SELinux策略说白了就是白名单原则，所以你需要非常清楚你的各项操作都需要哪些访问权限，以及哪些访问权限是可以允许的。