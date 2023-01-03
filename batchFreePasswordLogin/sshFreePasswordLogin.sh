#!/bin/bash

# shellcheck disable=SC2120
auto_gen_ssh_key() {
  expect -c "set timeout -1;
  spawn ssh-keygen;
	expect {
	  *(/root/.ssh/id_rsa)* {send -- \r;exp_continue;}
		*passphrase)* {send -- \r;exp_continue;}
		*again*	{send -- \r;exp_continue;}
		*(y/n)* {send -- y\r;exp_continue;}
		*password:* {send -- $1\r;exp_continue;}
		eof         {exit 0;}
	}";
}


auto_copy_id_to_all() {
  while read line;do
          ip=`echo $line | cut -d " " -f1`             # 提取文件中的ip
          username=`echo $line | cut -d " " -f2`       # 提取文件中的用户名
          password=`echo $line | cut -d " " -f3`       # 提取文件中的密码

          expect -c "set timeout -1;
            spawn ssh-copy-id ${username}@${ip}
            expect {
               *password:* {send -- ${password}\r;exp_continue;}
               *(yes/no)* {send -- yes\r;exp_continue;}
               eof         {exit 0;}
            }"
  done < /root/bin/ssh/hostConf      # 读取存储ip的文件
}

yum -y install expect

echo '1.生成密钥'
auto_gen_ssh_key

echo '2.实现免密'
auto_copy_id_to_all