#! /bin/bash

type=$1

soft_name=$2

case $type in
    "enable")
    sudo systemctl enable $soft_name
    echo "Service enabled"
    ;;
    "disable")
    sudo systemctl disable $soft_name
    echo "Service disabled"
    ;;
    "restart")
    sudo systemctl restart $soft_name
    echo "Service restarted"
    ;;
    "start")
    sudo systemctl start $soft_name
    echo "Service started"
    ;;
    "stop")
    sudo systemctl stop $soft_name
    echo "Service stopped"
    ;;
    *)
    echo "Wrong input"
    ;;
esac
