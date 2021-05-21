#! /bin/bash

templatepath=$1
variables=$2


variables=$(echo $variables|sed 's/vars://g')

nof=$(echo ${variables}|awk -F ","  '{ print NF }')


tempfile=$(cat $templatepath)

for ((i=1;i<=$nof;i++))
do
    line=$(echo ${variables}|awk -F ","  "{ print \$$i}")
    variable=$(echo ${line}|awk -F "=" '{print $1}')
    value=$(echo ${line}|awk -F "=" '{print $2}')
    tempfile=$(echo "$tempfile"|sed -e "s/{{$variable}}/$value/g")
done

echo "$tempfile">temp_file







