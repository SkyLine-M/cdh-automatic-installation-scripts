#!/bin/bash

current_path=$(cd $(dirname $0);pwd)
parent_path=$(dirname "${current_path}")

while read line; do
  ip=$(echo $line | cut -d " " -f1)       # 提取文件中的ip
  username=$(echo $line | cut -d " " -f2) # 提取文件中的用户名
  password=$(echo $line | cut -d " " -f3) # 提取文件中的密码
  hostname=$(echo $line | cut -d " " -f4) # 提取文件中的hostname
  yum -y install expect
  echo "服务器{$ip}修改Snappiness"
  expect -c "set timeout -1;
  spawn ssh ${username}@${ip} sed -i 's/^vm.swappiness\ =\ 30$/vm.swappiness\ =\ 10/'  /usr/lib/tuned/virtual-guest/tuned.conf
  expect {
     *password:* {send -- ${password}\r;exp_continue;}
     *(yes/no)* {send -- yes\r;exp_continue;}
     eof         {exit 0;}
  }"

  echo "服务器{$ip}修改/proc/sys/vm/swappiness"
  expect -c "set timeout -1;
  spawn ssh ${username}@${ip} echo 10 > /proc/sys/vm/swappiness
  expect {
     *password:* {send -- ${password}\r;exp_continue;}
     *(yes/no)* {send -- yes\r;exp_continue;}
     eof         {exit 0;}
  }"

done < ${parent_path}/conf/hostConf # 读取存储ip的文件


