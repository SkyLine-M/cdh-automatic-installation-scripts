#!/bin/bash

current_path=$(cd $(dirname $0);pwd)
parent_path=$(dirname "${current_path}")

while read line; do
  ip=$(echo $line | cut -d " " -f1)       # 提取文件中的ip
  username=$(echo $line | cut -d " " -f2) # 提取文件中的用户名
  password=$(echo $line | cut -d " " -f3) # 提取文件中的密码
  hostname=$(echo $line | cut -d " " -f4) # 提取文件中的hostname
  yum -y install expect
  echo "服务器{$ip}安装JDK"
  expect -c "set timeout -1;
  spawn ssh ${username}@${ip} yum -y install java-1.8.0-openjdk.x86_64 java-1.8.0-openjdk-headless.x86_64 java-1.8.0-openjdk-devel.x86_64
  expect {
     *password:* {send -- ${password}\r;exp_continue;}
     *(yes/no)* {send -- yes\r;exp_continue;}
     eof         {exit 0;}
  }"

done <${parent_path}/conf/hostConf # 读取存储ip的文件