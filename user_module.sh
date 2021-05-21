#!/bin/bash

type=$1

case $type in
    "create")
    username=$2
    conf=$3 
    pass=$4
    
    if [ "$conf" == "" ] 
    then
        sudo adduser -p $(openssl passwd -1 $pass) $username
    else
        sudo useradd --shell $conf -p $(openssl passwd -1 $pass) $username
    fi
        echo Created
    ;;
    "delete")
    username=$2
        sudo deluser $username
        echo "User deleted"
    ;;
    "modify")
    username=$2
    conf=$3
    line=$(cat /etc/passwd|grep $username|grep "/bin"|awk '{print $1}')
    ln=$(cat -n /etc/passwd|grep $username|grep "/bin"|awk '{print $1}')
    shell_type=$(echo $line|awk -F ":" '{print $7}'|sed 's,/bin/,,g')
    sudo sed -i "${ln}s,$shell_type,nologin," /etc/passwd
    ;;
esac


