#!/bin/bash

inven=$(cat -n inventory.txt)
hn=$1

if [ "$hn" != "all" ]
then
	tmp=$(grep "$hn" inventory.txt)
	if [ "$(echo $tmp|awk '{print $1}')" != "group:" ] 
	then
		while read line 
		do
			tmp=$(echo "$line"|grep "hostname: $hn")
			if [ "${tmp}" != "" ] 
			then
				line_number=$(echo "$tmp"|awk '{print $1}')
				line_number=$(echo $line_number|xargs)
				ip_n=$(echo $(($line_number+1)))
				key_n=$(echo $(($line_number+2)))
				ip=$(sed -n $ip_n\p inventory.txt|awk '{print $2}')
				key=$(sed -n $key_n\p inventory.txt|awk '{print $2}')
				echo $ip
				echo $key
				echo "-------------------"
			fi
		done < <(echo "$inven")
	elif [ "$(echo $tmp|awk '{print $1}')" == "group:" ] 
	then
		sl=$(cat -n inventory.txt|grep -o "^.*${hn}\$"|awk '{print $1}')
		sl=$(($sl+1))
		el=$(cat -n inventory.txt|grep -o "^.*${hn}\/\$"|awk '{print $1}')
		el=$(($el-1))
		inven=$(sed -n "$sl,${el}p" inventory.txt)
		while read line 
		do
			if [ "$(echo $line|grep "hostname:")" != "" ] 
			then
				line_number=$(cat -n inventory.txt|grep "$line"|awk '{print $1}')
				host_n=$line_number
				ip_n=$(($line_number+1))
				key_n=$(($line_number+2))
				host=$(sed -n "${host_n}p" inventory.txt|awk '{print $2}')
				ip=$(sed -n "${ip_n}p" inventory.txt|awk '{print $2}')
				key=$(sed -n "${key_n}p" inventory.txt|awk '{print $2}')
				echo $host
				echo $ip
				echo $key
				echo "---------------------------------------"
			fi
			
		done < <(echo "$inven")	
	else
		echo "Wrong input"	
	fi

elif [ "$hn" == "all" ] 
then
	while read line 
		do
			tmp=$(echo "$line"|grep "hostname: ")
			if [ "${tmp}" != "" ] 
			then
				line_number=$(echo "$tmp"|awk '{print $1}')
				line_number=$(echo $line_number|xargs)
				host=$(sed -n $line_number\p inventory.txt|awk '{print $2}')
				ip_n=$(echo $(($line_number+1)))
				key_n=$(echo $(($line_number+2)))
				ip=$(sed -n $ip_n\p inventory.txt|awk '{print $2}')
				key=$(sed -n $key_n\p inventory.txt|awk '{print $2}')
				echo $ip
				echo $key
				echo "-------------------"
			fi
		done < <(echo "$inven")	
fi



