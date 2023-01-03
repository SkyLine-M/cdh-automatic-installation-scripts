#!/bin/bash

current_path=$(cd $(dirname $0);pwd)
parent_path=$(dirname "${current_path}")

while read line; do
  ip=$(echo $line | cut -d " " -f1)       # 提取文件中的ip
  username=$(echo $line | cut -d " " -f2) # 提取文件中的用户名
  password=$(echo $line | cut -d " " -f3) # 提取文件中的密码
  hostname=$(echo $line | cut -d " " -f4) # 提取文件中的hostname
  yum -y install expect
  echo "服务器{$ip}关闭防火墙"
  expect -c "set timeout -1;
  spawn ssh ${username}@${ip} systemctl stop firewalld.service
  expect {
     *password:* {send -- ${password}\r;exp_continue;}
     *(yes/no)* {send -- yes\r;exp_continue;}
     eof         {exit 0;}
  }"

  echo "服务器{$ip}禁用防火墙开机启动"
  expect -c "set timeout -1;
  spawn ssh ${username}@${ip} systemctl disable firewalld.service
  expect {
     *password:* {send -- ${password}\r;exp_continue;}
     *(yes/no)* {send -- yes\r;exp_continue;}
     eof         {exit 0;}
  }"

  echo "服务器{$ip}安装iptables"
  expect -c "set timeout -1;
  spawn ssh ${username}@${ip} yum -y install iptables
  expect {
     *password:* {send -- ${password}\r;exp_continue;}
     *(yes/no)* {send -- yes\r;exp_continue;}
     eof         {exit 0;}
  }"

  echo "服务器{$ip}安装iptables-services"
  expect -c "set timeout -1;
  spawn ssh ${username}@${ip} yum -y install iptables-services
  expect {
     *password:* {send -- ${password}\r;exp_continue;}
     *(yes/no)* {send -- yes\r;exp_continue;}
     eof         {exit 0;}
  }"


  echo "服务器{$ip}关闭iptables"
  expect -c "set timeout -1;
  spawn ssh ${username}@${ip} systemctl stop iptables.service
  expect {
     *password:* {send -- ${password}\r;exp_continue;}
     *(yes/no)* {send -- yes\r;exp_continue;}
     eof         {exit 0;}
  }"

  echo "服务器{$ip}禁用iptables开机启动"
  expect -c "set timeout -1;
  spawn ssh ${username}@${ip} systemctl disable iptables.service
  expect {
     *password:* {send -- ${password}\r;exp_continue;}
     *(yes/no)* {send -- yes\r;exp_continue;}
     eof         {exit 0;}
  }"

  echo "服务器{$ip}临时关闭SELINUX(为的是不重启服务器)"
  expect -c "set timeout -1;
  spawn ssh ${username}@${ip} setenforce 0
  expect {
     *password:* {send -- ${password}\r;exp_continue;}
     *(yes/no)* {send -- yes\r;exp_continue;}
     eof         {exit 0;}
  }"

  echo "服务器{$ip}永久关闭SELINUX"
  expect -c "set timeout -1;
  spawn ssh ${username}@${ip} sed -i "s/^SELINUX=.*$/SELINUX=disabled/" /etc/selinux/config
  expect {
     *password:* {send -- ${password}\r;exp_continue;}
     *(yes/no)* {send -- yes\r;exp_continue;}
     eof         {exit 0;}
  }"

done < ${parent_path}/conf/hostConf # 读取存储ip的文件


