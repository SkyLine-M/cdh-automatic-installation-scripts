#!/bin/bash

declare -i x=1
current_path=$(cd $(dirname $0);pwd)
parent_path=$(dirname "${current_path}")

sed -i 's/\r//' ${parent_path}/conf/hostConf
sed -i 's/\r//' ${current_path}/clouderaManagerRepoConf

clouderaManagerRepoConf=""

# clouderaManagerRepoConf
while read line; do
  clouderaManagerRepoConf=${clouderaManagerRepoConf}`echo "${line}\n"`
done < ${current_path}/clouderaManagerRepoConf



while read line; do
  ip=$(echo $line | cut -d " " -f1)       # 提取文件中的ip
  username=$(echo $line | cut -d " " -f2) # 提取文件中的用户名
  password=$(echo $line | cut -d " " -f3) # 提取文件中的密码
  hostname=$(echo $line | cut -d " " -f4) # 提取文件中的hostname
  yum -y install expect

  if [ $x -eq 1 ]; then
    clouderaManagerRepoConf=${clouderaManagerRepoConf//masterIp/${ip}}
    # 在hostConf中的第一个服务器上配置本地yum源
    echo "服务器{$ip}安装Apache http"
    expect -c "set timeout -1;
      spawn ssh ${username}@${ip} yum install -y httpd
      expect {
         *password:* {send -- ${password}\r;exp_continue;}
         *(yes/no)* {send -- yes\r;exp_continue;}
         eof         {exit 0;}
      }"

    echo "服务器{$ip}启动Apache http"
    expect -c "set timeout -1;
      spawn ssh ${username}@${ip} systemctl start httpd
      expect {
         *password:* {send -- ${password}\r;exp_continue;}
         *(yes/no)* {send -- yes\r;exp_continue;}
         eof         {exit 0;}
      }"

    echo "服务器{$ip}设置自启动Apache http"
    expect -c "set timeout -1;
      spawn ssh ${username}@${ip} systemctl enable httpd
      expect {
         *password:* {send -- ${password}\r;exp_continue;}
         *(yes/no)* {send -- yes\r;exp_continue;}
         eof         {exit 0;}
      }"

    echo "服务器{$ip}创建安装文件http根目录"
    expect -c "set timeout -1;
      spawn ssh ${username}@${ip} mkdir -p /var/www/html/cmRepo
      expect {
         *password:* {send -- ${password}\r;exp_continue;}
         *(yes/no)* {send -- yes\r;exp_continue;}
         eof         {exit 0;}
      }"

    echo "服务器{$ip}移动安装包到指定目录"
    expect -c "set timeout -1;
      spawn ssh ${username}@${ip} mv ${parent_path}/package/cmAgentAndServer/* /var/www/html/cmRepo/
      expect {
         *password:* {send -- ${password}\r;exp_continue;}
         *(yes/no)* {send -- yes\r;exp_continue;}
         eof         {exit 0;}
      }"

    echo "服务器{$ip}创建yum仓库"
    expect -c "set timeout -1;
      spawn ssh ${username}@${ip} \"yum install -y createrepo;createrepo /var/www/html/cmRepo\"
      expect {
         *password:* {send -- ${password}\r;exp_continue;}
         *(yes/no)* {send -- yes\r;exp_continue;}
         eof         {exit 0;}
      }"
  fi

  echo "服务器{$ip}配置yum仓库文件"
  expect -c "set timeout -1;
    spawn ssh ${username}@${ip} echo '\[cloudera-manager\]' > /etc/yum.repos.d/cloudera-manager.repo
    expect {
       *password:* {send -- ${password}\r;exp_continue;}
       *(yes/no)* {send -- yes\r;exp_continue;}
       eof         {exit 0;}
        }"
  expect -c "set timeout -1;
    spawn ssh ${username}@${ip} echo -e '${clouderaManagerRepoConf}' >> /etc/yum.repos.d/cloudera-manager.repo
    expect {
       *password:* {send -- ${password}\r;exp_continue;}
       *(yes/no)* {send -- yes\r;exp_continue;}
       eof         {exit 0;}
        }"

  echo "服务器{$ip}更新本地仓库信息"
  expect -c "set timeout -1;
    spawn ssh ${username}@${ip} \"yum clean all;yum makecache\"
    expect {
       *password:* {send -- ${password}\r;exp_continue;}
       *(yes/no)* {send -- yes\r;exp_continue;}
       eof         {exit 0;}
        }"

  x+=1
done <${parent_path}/conf/hostConf # 读取存储ip的文件
