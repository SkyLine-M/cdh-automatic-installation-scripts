#!/bin/bash

declare -i x=1
current_path=$(cd $(dirname $0);pwd)
parent_path=$(dirname "${current_path}")

ntpServerConf=""
ntpClientConf=""
masterIp=""

# 读取ntpServerConf
while read line; do
  ntpServerConf=${ntpServerConf}`echo "${line}\n"`
done < ${current_path}/ntpServerConf

# 读取ntpClientConf
while read line; do
  ntpClientConf=${ntpClientConf}`echo "${line}\n"`
done < ${current_path}/ntpClientConf


while read line; do
  ip=$(echo $line | cut -d " " -f1)       # 提取文件中的ip
  username=$(echo $line | cut -d " " -f2) # 提取文件中的用户名
  password=$(echo $line | cut -d " " -f3) # 提取文件中的密码
  hostname=$(echo $line | cut -d " " -f4) # 提取文件中的hostname
  yum -y install expect
  echo "服务器{$ip}安装NTP服务"
  expect -c "set timeout -1;
  spawn ssh ${username}@${ip} yum install -y ntp
  expect {
     *password:* {send -- ${password}\r;exp_continue;}
     *(yes/no)* {send -- yes\r;exp_continue;}
     eof         {exit 0;}
  }"

  echo "服务器{$ip}配置NTP服务为自启动"
  expect -c "set timeout -1;
  spawn ssh ${username}@${ip} systemctl enable ntpd.service
  expect {
     *password:* {send -- ${password}\r;exp_continue;}
     *(yes/no)* {send -- yes\r;exp_continue;}
     eof         {exit 0;}
  }"

  echo "服务器{$ip}使用ntpdate手动同步时间"
  expect -c "set timeout -1;
  spawn ssh ${username}@${ip} ntpdate -u 202.112.10.36
  expect {
     *password:* {send -- ${password}\r;exp_continue;}
     *(yes/no)* {send -- yes\r;exp_continue;}
     eof         {exit 0;}
  }"

  if [ $x -eq 1 ]; then
    # 替换ntpClientConf中的主机ip配置
    masterIp=${ip}
    ntpClientConf=${ntpClientConf//ntpServerIP/${masterIp}}
    echo "服务器{$ip}配置NTP-Server"
    expect -c "set timeout -1;
      spawn ssh ${username}@${ip} echo '${ntpServerConf}' >> /etc/ntp.conf
      expect {
         *password:* {send -- ${password}\r;exp_continue;}
         *(yes/no)* {send -- yes\r;exp_continue;}
         eof         {exit 0;}
      }"

    echo "服务器{$ip}启动NTPD服务"
    expect -c "set timeout -1;
      spawn ssh ${username}@${ip} systemctl start ntpd.service
      expect {
         *password:* {send -- ${password}\r;exp_continue;}
         *(yes/no)* {send -- yes\r;exp_continue;}
         eof         {exit 0;}
      }"
  else
    echo "服务器{$ip}配置NTP-Client"
    expect -c "set timeout -1;
      spawn ssh ${username}@${ip} echo '${ntpClientConf}' >> /etc/ntp.conf
      expect {
         *password:* {send -- ${password}\r;exp_continue;}
         *(yes/no)* {send -- yes\r;exp_continue;}
         eof         {exit 0;}
      }"

    echo "服务器{$ip}Client手动同步时间"
    expect -c "set timeout -1;
      spawn ssh ${username}@${ip} ntpdate -u ${masterIp}
      expect {
         *password:* {send -- ${password}\r;exp_continue;}
         *(yes/no)* {send -- yes\r;exp_continue;}
         eof         {exit 0;}
      }"
    echo "服务器{$ip}启动NTPD服务"
    expect -c "set timeout -1;
      spawn ssh ${username}@${ip} systemctl start ntpd.service
      expect {
         *password:* {send -- ${password}\r;exp_continue;}
         *(yes/no)* {send -- yes\r;exp_continue;}
         eof         {exit 0;}
      }"
  fi

  x+=1
done <${parent_path}/conf/hostConf # 读取存储ip的文件
