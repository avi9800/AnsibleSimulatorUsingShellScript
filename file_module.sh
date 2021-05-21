#!/bin/bash

state=$1


case $state in
    "touch")
    path=$2
    owner=$3
    group=$4
    touch $path
    sudo chown $owner:$group $path
    echo "File created"
    ;;
    "link")
    path=$2
    src=$3
    ln -s $path $src
    echo "Link created"
    ;;
    "directory")
    path=$2
    mkdir $path
    echo "Directory created" 
    ;;
    "absent")
    path=$2
    rm -r $path
    echo "Deleted"
    ;;
    *)
    echo "Wrong input"
    ;;
esac
