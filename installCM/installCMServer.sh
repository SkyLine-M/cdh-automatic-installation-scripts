#!/bin/bash

declare -i x=1
current_path=$(cd $(dirname $0);pwd)
parent_path=$(dirname "${current_path}")


while read line; do
  ip=$(echo $line | cut -d " " -f1)       # 提取文件中的ip
  username=$(echo $line | cut -d " " -f2) # 提取文件中的用户名
  password=$(echo $line | cut -d " " -f3) # 提取文件中的密码
  yum -y install expect

  if [ $x -eq 1 ]; then
      echo "服务器${ip}安装cloudera-manager-server"
      expect -c "set timeout -1;
      spawn ssh ${username}@${ip} yum install -y cloudera-manager-server
      expect {
         *password:* {send -- ${password}\r;exp_continue;}
         *(yes/no)* {send -- yes\r;exp_continue;}
         eof         {exit 0;}
      }"

      echo "服务器${ip}创建cmServer安装包路径,其实安装完CMServer的时候已经创建了，这里是保险操作"
      expect -c "set timeout -1;
      spawn ssh ${username}@${ip} mkdir -p /opt/cloudera/parcel-repo
      expect {
         *password:* {send -- ${password}\r;exp_continue;}
         *(yes/no)* {send -- yes\r;exp_continue;}
         eof         {exit 0;}
      }"

      echo "服务器${ip}移动CDH的包到这里"
      expect -c "set timeout -1;
      spawn ssh ${username}@${ip} mv ${parent_path}/package/cdh/* /opt/cloudera/parcel-repo/
      expect {
         *password:* {send -- ${password}\r;exp_continue;}
         *(yes/no)* {send -- yes\r;exp_continue;}
         eof         {exit 0;}
      }"


      echo "服务器${ip}执行CM初始化脚本"
      expect -c "set timeout -1;
      spawn ssh ${username}@${ip} /opt/cloudera/cm/schema/scm_prepare_database.sh mysql cmserver root root
      expect {
         *password:* {send -- ${password}\r;exp_continue;}
         *(yes/no)* {send -- yes\r;exp_continue;}
         eof         {exit 0;}
      }"

      echo "服务器${ip}启动cloudera-manager-server"
      expect -c "set timeout -1;
      spawn ssh ${username}@${ip} systemctl start cloudera-scm-server.service
      expect {
         *password:* {send -- ${password}\r;exp_continue;}
         *(yes/no)* {send -- yes\r;exp_continue;}
         eof         {exit 0;}
      }"
  fi

  x+=1
done < ${parent_path}/conf/hostConf # 读取存储ip的文件