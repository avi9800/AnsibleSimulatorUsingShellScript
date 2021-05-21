#!/bin/bash

type=$1

soft_name=$2

case $type in
    "install")
    sudo apt -y install $soft_name
    echo "Software installed"
    ;;
    "remove")
    sudo apt -y remove $soft_name
    echo "Software removed"
    ;;
    "update")
    sudo apt -y update
    echo "Updated" 
    ;;
    "upgrade")
    sudo apt -y upgrade
    echo "Upgraded" 
    ;;
    *)
    echo "Wrong input"
    ;;
esac
