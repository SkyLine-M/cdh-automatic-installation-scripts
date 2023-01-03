## 本脚本用于安装mysql

1. 编写好../conf/hostConf文件
2. 编写./init/init.sql文件，这个脚本里放的是mysql的初始化语句
3. 编写./dockerComposeMysql.yml文件，这个文件是docker-compose的yml文件
4. 在集群中某一台机器上执行下面脚本即可。
```shell
sh batchSetTimeZone.sh
```