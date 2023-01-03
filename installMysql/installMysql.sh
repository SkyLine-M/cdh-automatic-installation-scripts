#!/bin/bash

current_path=$(cd $(dirname $0);pwd)
parent_path=$(dirname "${current_path}")

sh ${current_path}/getMysqlConnectJar.sh
docker-compose -f ${current_path}/dockerComposeMysql.yml up -d
