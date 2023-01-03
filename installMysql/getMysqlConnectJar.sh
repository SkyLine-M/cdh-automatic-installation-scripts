#!/bin/bash

declare -i x=1
current_path=$(cd $(dirname $0);pwd)
parent_path=$(dirname "${current_path}")

masterIp=""

while read line; do
  ip=$(echo $line | cut -d " " -f1)       # 提取文件中的ip
  username=$(echo $line | cut -d " " -f2) # 提取文件中的用户名
  password=$(echo $line | cut -d " " -f3) # 提取文件中的密码
  yum -y install expect

  if [ $x -eq 1 ]; then
      # 替换ntpClientConf中的主机ip配置
      masterIp=${ip}
  fi

  echo "服务器${ip}创建存放mysql-connector-jar的目录"
  expect -c "set timeout -1;
  spawn ssh ${username}@${ip} \"mkdir -p /usr/share/java;cd /usr/share/java\"
  expect {
     *password:* {send -- ${password}\r;exp_continue;}
     *(yes/no)* {send -- yes\r;exp_continue;}
     eof         {exit 0;}
  }"

  echo "服务器${ip}创建脚本目录"
  expect -c "set timeout -1;
  spawn ssh ${username}@${ip} \"cd /usr/share/java;wget http://${masterIp}/cmRepo/mysql-connector-java-8.0.17.jar;mv mysql-connector-java-8.0.17.jar mysql-connector-java.jar\"
  expect {
     *password:* {send -- ${password}\r;exp_continue;}
     *(yes/no)* {send -- yes\r;exp_continue;}
     eof         {exit 0;}
  }"

  x+=1
done < ${parent_path}/conf/hostConf # 读取存储ip的文件