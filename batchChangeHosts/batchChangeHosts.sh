#!/bin/bash

current_path=$(cd $(dirname $0);pwd)
parent_path=$(dirname "${current_path}")

hosts=""
echodomain(){
  while read line; do
    ip=$(echo $line | cut -d " " -f1)       # 提取文件中的ip
    username=$(echo $line | cut -d " " -f2) # 提取文件中的用户名
    password=$(echo $line | cut -d " " -f3) # 提取文件中的密码
    hostname=$(echo $line | cut -d " " -f4) # 提取文件中的hostname
    domain=$(echo $line | cut -d " " -f5)   # 提取文件中的domain
    # 批量修改主机名
    hosts=${hosts}`echo "${ip} ${domain} ${hostname}\n"`
  done < ${parent_path}/conf/hostConf # 读取存储ip的文件
}

echodomain

while read line; do
  ip=$(echo $line | cut -d " " -f1)       # 提取文件中的ip
  username=$(echo $line | cut -d " " -f2) # 提取文件中的用户名
  password=$(echo $line | cut -d " " -f3) # 提取文件中的密码
  hostname=$(echo $line | cut -d " " -f4) # 提取文件中的hostname
  domain=$(echo $line | cut -d " " -f5)   # 提取文件中的domain
  yum -y install expect
  # 批量修改主机名
  echo "服务器{$ip}修改hosts"
  expect -c "set timeout -1;
  spawn ssh ${username}@${ip} echo '${hosts}' >> /etc/hosts
  expect {
     *password:* {send -- ${password}\r;exp_continue;}
     *(yes/no)* {send -- yes\r;exp_continue;}
     eof         {exit 0;}
  }"

done < ${parent_path}/conf/hostConf # 读取存储ip的文件
