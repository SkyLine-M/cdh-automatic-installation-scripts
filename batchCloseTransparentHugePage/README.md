## 本脚本用于禁用透明大页

1. 编写好../conf/hostConf文件

2. 在集群中某一台机器上执行下面脚本即可。
```shell
sh batchCloseTransparentHugePage.sh
```

## 关闭原因

> 现在绝大多数的系统都是使用透明大页，而透明大页的作用是将内存中的大页面分割成小页面，这样就可以提高内存的使用效率，但是这样的话会导致内存的占用增加，所以我们需要关闭透明大页。

## cloudera官网说明

https://docs.cloudera.com/documentation/enterprise/latest/topics/cdh_admin_performance.html#cdh_performance__section_hw3_sdf_jq