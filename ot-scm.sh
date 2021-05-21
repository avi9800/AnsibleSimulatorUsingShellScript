#!/bin/bash

module=$1

function user_mod()
{
    hostname=$1
    type=$2
    user=$3
    pass=$4
    conf=$5

    if [ "$type" != "create" ] && [ "$type" != "delete" ] && [ "$type" != "modify" ]
    then
        echo "Wrong type input"
        return
    fi
    #_______________________________________________________________________#

    inven=$(cat -n inventory.txt)
    hn=$hostname

    if [ "$hn" != "all" ]
    then
        tmp=$(grep "$hn" inventory.txt)
        if [ "$(echo $tmp|awk '{print $1}')" != "group:" ]              #Non grouped user condition
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
                    ssh -i $key $hn@$ip 'bash -s'<user_module.sh $type $user $conf $pass #main command
                fi
            done < <(echo "$inven")
        elif [ "$(echo $tmp|awk '{print $1}')" == "group:" ]            #group name given
        then
            sl=$(cat -n inventory.txt|grep -o "^.*${hn}\$"|awk '{print $1}')        #Taking the starting group hostname line number
            sl=$(($sl+1))
            el=$(cat -n inventory.txt|grep -o "^.*${hn}\/\$"|awk '{print $1}')      #Taking the last group hostname line number
            el=$(($el-1))
            inven=$(sed -n "$sl,${el}p" inventory.txt)                              #Extracting the group
            while read line 
            do
                if [ "$(echo $line|grep "hostname:")" != "" ] 
                then
                    line_number=$(cat -n inventory.txt|grep "$line"|awk '{print $1}')
                    host_n=$line_number
                    ip_n=$(($line_number+1))                                                #Taking the ip address linenumber and then extracting the ip 
                    key_n=$(($line_number+2))                                               #Taking the key linenumber and then extracting the key
                    host=$(sed -n "${host_n}p" inventory.txt|awk '{print $2}')
                    ip=$(sed -n "${ip_n}p" inventory.txt|awk '{print $2}')
                    key=$(sed -n "${key_n}p" inventory.txt|awk '{print $2}')
                    ssh $host@$ip 'bash -s'<user_module.sh $type $user $conf $pass #main command
                fi
                
            done < <(echo "$inven")	
        else
            echo "Wrong input"	
        fi

    elif [ "$hn" == "all" ]                     #Sending to all hosts
    then
        while read line 
            do
                tmp=$(echo "$line"|grep "hostname: ")
                if [ "${tmp}" != "" ] 
                then
                    line_number=$(echo "$tmp"|awk '{print $1}')
                    line_number=$(echo $line_number|xargs)
                    hn=$(sed -n $line_number\p inventory.txt|awk '{print $2}')
                    ip_n=$(echo $(($line_number+1)))
                    key_n=$(echo $(($line_number+2)))
                    ip=$(sed -n $ip_n\p inventory.txt|awk '{print $2}')
                    key=$(sed -n $key_n\p inventory.txt|awk '{print $2}')
                    ssh $hn@$ip 'bash -s'<user_module.sh $type $user $conf $pass #main command
                fi
            done < <(echo "$inven")	
    fi

    #_______________________________________________________________________#

    
}

##################################################################################################

function file_mod()
{
    hostname=$1
    state=$2
    path=$3
    owner=$4
    group=$5

    if [ "$state" != "touch" ] && [ "$state" != "absent" ] && [ "$state" != "directory" ] && [ "$state" != "link" ]
    then
        echo "Wrong state input"
        return
    fi

    inven=$(cat -n inventory.txt)
    hn=$hostname

#_________________________________________________________________________________________#


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
                    if [ "$state" == "link" ] 
                    then
                        ssh $hn@$ip 'bash -s'<file_module.sh $state $path $src #main command        #creating without owner and group
                    else    
                        ssh $hn@$ip 'bash -s'<file_module.sh $state $path $owner $group #main command  #creating with owner and group
                    fi
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
                    if [ "$state" == "link" ] 
                    then
                        ssh $host@$ip 'bash -s'<file_module.sh $state $path $src #main command
                    else    
                        ssh $host@$ip 'bash -s'<file_module.sh $state $path $owner $group #main command
                    fi
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
                    if [ "$state" == "link" ] 
                    then
                        ssh $host@$ip 'bash -s'<file_module.sh $state $path $src #main command
                    else    
                        ssh $host@$ip 'bash -s'<file_module.sh $state $path $owner $group #main command
                    fi
                fi
            done < <(echo "$inven")	
    fi


#_________________________________________________________________________________________#

}

##################################################################################################

function package_mod()
{
    hostname=$1

    type=$2

    soft_name=$3

    if [ "$type" != "install" ] && [ "$type" != "update" ] && [ "$type" != "remove" ]
    then
        echo "Wrong type input"
        return
    fi

    

    inven=$(cat -n inventory.txt)
    hn=$hostname

#________________________________________________________________________________________________#



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
                    ssh $hn@$ip 'bash -s'<package_module.sh $type $soft_name #main command
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
                    ssh $host@$ip 'bash -s'<package_module.sh $type $soft_name #main command
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
                    ssh $host@$ip 'bash -s'<package_module.sh $type $soft_name #main command
                fi
            done < <(echo "$inven")	
    fi


#_________________________________________________________________________________________#

}

##################################################################################################

function service_mod()
{
    hostname=$1
    type=$2
    soft_name=$3

    if [ "$type" != "enable" ] && [ "$type" != "start" ] && [ "$type" != "stop" ] && [ "$type" != "restart" ]
    then
        echo "Wrong type input"
        return
    fi

    inven=$(cat -n inventory.txt)
    hn=$hostname

    #________________________________________________________________________________________________#



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
                    ssh $hn@$ip 'bash -s'<service_module.sh $type $soft_name #main command
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
                    ssh $host@$ip 'bash -s'<service_module.sh $type $soft_name #main command
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
                    ssh $host@$ip 'bash -s'<service_module.sh $type $soft_name #main command
                fi
            done < <(echo "$inven")	
    fi


#_________________________________________________________________________________________#
    
}

##################################################################################################

function copy_mod()
{
    hostname1=$1
    hostname2=$2
    typeofsrc1=$3
    path1=$4
    typeofsrc2=$5
    path2=$6

    inven=$(cat -n inventory.txt)
    hn1=$hostname1
    hn2=$hostname2

    while read line   #Fetching ip and key of first remote host
    do
        tmp=$(echo "$line"|grep "hostname: $hn1")
        if [ "${tmp}" != "" ] 
        then
            line_number=$(echo "$tmp"|awk '{print $1}')
            line_number=$(echo $line_number|xargs)
            ip_n=$(echo $(($line_number+1)))
            key_n=$(echo $(($line_number+2)))
            ip1=$(sed -n $ip_n\p inventory.txt|awk '{print $2}')
            key1=$(sed -n $key_n\p inventory.txt|awk '{print $2}')            
        fi
    done < <(echo "$inven")

    mkdir tmp_file

    scp -i $key1 $hostname1@$ip1:/$path1 tmp_file
    
    fn=$(ls tmp_file)


    #________________________________________________________________________________________________#



    if [ "$hn2" != "all" ]
    then
        tmp=$(grep "$hn2" inventory.txt)
        if [ "$(echo $tmp|awk '{print $1}')" != "group:" ] 
        then
            while read line 
            do
                tmp=$(echo "$line"|grep "hostname: $hn2")
                if [ "${tmp}" != "" ] 
                then
                    line_number=$(echo "$tmp"|awk '{print $1}')
                    line_number=$(echo $line_number|xargs)
                    ip_n=$(echo $(($line_number+1)))
                    key_n=$(echo $(($line_number+2)))
                    ip=$(sed -n $ip_n\p inventory.txt|awk '{print $2}')
                    key=$(sed -n $key_n\p inventory.txt|awk '{print $2}')
                    scp -i $key tmp_file/$fn $hn2@$ip:/$path2  #copying to second host
                fi
            done < <(echo "$inven")
        elif [ "$(echo $tmp|awk '{print $1}')" == "group:" ] 
        then
            sl=$(cat -n inventory.txt|grep -o "^.*${hn2}\$"|awk '{print $1}')
            sl=$(($sl+1))
            el=$(cat -n inventory.txt|grep -o "^.*${hn2}\/\$"|awk '{print $1}')
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
                    scp -i $key tmp_file/$fn $host@$ip:/$path2  #copying to second host
                fi
                
            done < <(echo "$inven")	
        else
            echo "Wrong input"	
        fi

    elif [ "$hn2" == "all" ] 
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
                    scp -i $key tmp_file/$fn $host@$ip:/$path2  #copying to second host
                fi
            done < <(echo "$inven")	
    fi

    rm -r tmp_file


#_________________________________________________________________________________________#

}

##################################################################################################

function fetch_mod()
{
    hostname=$1
    typeofsrc1=$2
    path1=$3
    typeofsrc2=$4
    path2=$5
    typeofcp=$6

    inven=$(cat -n inventory.txt)
    hn=$hostname

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
        fi
    done < <(echo "$inven")


    if [ "$typeofcp" == "rl" ] 
    then
        scp -i $key $hostname@$ip:$path1 $path2
    elif [ "$typeofcp" == "lr" ] 
    then
        scp -i $key $path1 $hostname@$ip:$path2
    fi
        echo "Copied"
}

##################################################################################################

function template_mod()
{
    hostname=$1
    templatepath=$2
    remote_src_dest=$3
    vars=$4

    bash template_module.sh $templatepath $vars 
    cat temp_file

    inven=$(cat -n inventory.txt)
    hn=$hostname

    #________________________________________________________________________________________________#



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
                    scp -i $key temp_file $hn@$ip:$remote_src_dest 
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
                    scp -i $key temp_file $host@$ip:$remote_src_dest 
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
                    scp -i $key temp_file $host@$ip:$remote_src_dest 
                fi
            done < <(echo "$inven")	
    fi


#_________________________________________________________________________________________#


    rm temp_file




}

##################################################################################################

function edit_mod()
{
    datatoadd="$1"
    destination=$2
    hostname=$3

    if [ "$datatoadd" == "" ] 
    then
        echo "Nothing to add"
        return
    fi



    inven=$(cat -n inventory.txt)
    hn=$hostname

    #________________________________________________________________________________________________#



    if [ "$hn" != "all" ]
    then
        tmp=$(grep "$hn" inventory.txt)
        if [ "$(echo $tmp|awk '{print $1}')" != "group:" ] 
        then
            while read line 
            do
                tmp=$(echo "$line"|grep "hostname: $hn")
                u=$(whoami)
                rm /home/$u/tmp
                if [ "${tmp}" != "" ] 
                then
                    line_number=$(echo "$tmp"|awk '{print $1}')
                    line_number=$(echo $line_number|xargs)
                    ip_n=$(echo $(($line_number+1)))
                    key_n=$(echo $(($line_number+2)))
                    ip=$(sed -n $ip_n\p inventory.txt|awk '{print $2}')
                    key=$(sed -n $key_n\p inventory.txt|awk '{print $2}')
                    u=$(whoami)        
                    scp -i $key $hn@$ip:$destination /home/$u/tmp
                    echo "Before addition ------------------------>"
                    cat /home/$u/tmp
                    echo -e "${datatoadd}">>/home/$u/tmp
                    echo "After addition ------------------------>"
                    cat /home/$u/tmp
                    ssh $host@$ip "rm $destination"
                    scp -i $key /home/$u/tmp $hn@$ip:$destination 
                    rm /home/$u/tmp
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
                u=$(whoami)
                rm /home/$u/tmp
                if [ "$(echo $line|grep "hostname:")" != "" ] 
                then
                    line_number=$(cat -n inventory.txt|grep "$line"|awk '{print $1}')
                    host_n=$line_number
                    ip_n=$(($line_number+1))
                    key_n=$(($line_number+2))
                    host=$(sed -n "${host_n}p" inventory.txt|awk '{print $2}')
                    ip=$(sed -n "${ip_n}p" inventory.txt|awk '{print $2}')
                    key=$(sed -n "${key_n}p" inventory.txt|awk '{print $2}')
                    u=$(whoami)        
                    scp -i $key $host@$ip:$destination /home/$u/tmp
                    echo "Before addition ------------------------>"
                    cat /home/$u/tmp
                    echo -e "${datatoadd}">>/home/$u/tmp
                    echo "After addition ------------------------>"
                    cat /home/$u/tmp
                    ssh $host@$ip "rm $destination"
                    scp -i $key /home/$u/tmp $host@$ip:$destination 
                    rm /home/$u/tmp
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
                u=$(whoami)
                rm /home/$u/tmp
                if [ "${tmp}" != "" ] 
                then
                    line_number=$(echo "$tmp"|awk '{print $1}')
                    line_number=$(echo $line_number|xargs)
                    host=$(sed -n $line_number\p inventory.txt|awk '{print $2}')
                    ip_n=$(echo $(($line_number+1)))
                    key_n=$(echo $(($line_number+2)))
                    ip=$(sed -n $ip_n\p inventory.txt|awk '{print $2}')
                    key=$(sed -n $key_n\p inventory.txt|awk '{print $2}')
                    
                    u=$(whoami)    
                    scp -i $key $host@$ip:$destination /home/$u/tmp
                    echo "Before addition ------------------------>"
                    cat /home/$u/tmp
                    echo -e "${datatoadd}">>/home/$u/tmp
                    echo "After addition ------------------------>"
                    cat /home/$u/tmp
                    ssh $host@$ip "rm $destination"
                    scp -i $key /home/$u/tmp $host@$ip:$destination 
                    rm /home/$u/tmp
                fi
            done < <(echo "$inven")	
    fi


#_________________________________________________________________________________________#


    echo "Data added"
}

##################################################################################################

function arg_help(){
    echo "1. User Module
Using this module we can create a user, delete a user and modify it.
Format:- bash ot-scm.sh user -h <hostname> <option> <username> -p <password> -s /bin/<shelltype>
option:-
create- create user
delete- delete user
modify- modify user configuration

2. File Module 
This module will be used to create, delete a file and directory, symbolic link etc.
Format:- bash ot-scm.sh file -h <hostname> state=<option> path=<path_of_file>
option:-
touch- To create a new file
absent- To delete a file/directory
directory- To create a directory
link- To create a soft link

3. Package Module
This module will be used to install packages in remote instance.
Format:- bash ot-scm.sh -h <hostname> <type> <software_name>
type:-
install- To install a package
update- To update a package
remove- To remove a package

4. Service Module
This module will be used to restart, start and stop a service.
Format:- bash ot-scm.sh -h <hostname> <type> <service_name>
type:-
enable- To start a service on boot
start- To stop a service
stop- To stop a service
restart- To restart a service

5. Copy Module
This tool will be used to copy a file.
Format:- bash ot-scm.sh -h <hostname1> local-src/remote-src <src path> local-src/remote-src <src path> -h <hostname2>

6. Template Module
This module will be used as a template to modify the file at run time
Format:- bash ot-scm.sh template -h <hostname> <template_path> remote-src <remote_src_dest> vars:<var1=value1,var2=value2...>

7. Edit Module
This module will be used to add data to existing file in server
Format:- bash ot-scm.sh '<datatoadd>' remote-src <destination> -h <hostname>
    "
}


##################################################################################################

case $module in
    "user")
    if (( ${#} != 9 )) 
    then
        echo "Incorrect number of arguments. Please refer to arg_help"
        exit 
    fi
    #bash ot-scm.sh user -h hostname type username -p password -s /bin/bash
    shift
    shift
    hostname=$1
    shift
    type=$1
    shift
    user=$1
    shift
    shift
    pass=$1
    shift
    shift
    conf=$1
    if [ "$(grep -w ${hostname} inventory.txt)" == "" ] 
    then
        echo "Host not present"
    else
        user_mod $hostname $type $user $pass $conf
    fi
    ;;
    "file")    #bash ot-scm.sh file -h <hostname> state=<option> path=<path_of_file>
    if (( ${#} != 5 )) 
    then
        echo "Incorrect number of arguments. Please refer to arg_help"
        exit 
    fi
    shift
    shift
    hostname=$1
    shift
    state=$(echo -e $1|sed "s/state=//g")
    shift
    path=$(echo -e $1|sed "s/path=//g")
    shift
    if [ "$state" == "link" ] 
    then
        src=$(echo -e $1|sed "s/src=//g")
            if [ "$(grep -w ${hostname} inventory.txt)" == "" ] 
            then
                echo "Host not present"
            else
                file_mod $hostname $state $path $src
            fi
    else 
        owner=$(echo -e $1|sed "s/owner=//g")
        shift
        group=$(echo -e $1|sed "s/group=//g")
        if [ "$(grep -w ${hostname} inventory.txt)" == "" ] 
        then
            echo "Host not present"
        else
            file_mod $hostname $state $path $owner $group
        fi
    fi
    ;;
    "package")      #bash ot-scm.sh -h <hostname> <type> <software_name> 
    if (( ${#} != 4  || ${#} != 3 )) 
    then
        echo "Incorrect number of arguments. Please refer to arg_help"
        exit 
    fi
    shift
    shift
    hostname=$1
    shift
    type=$1
    shift
    soft_name=$1
    if [ "$(grep -w ${hostname} inventory.txt)" == "" ] 
    then
        echo "Host not present"
    else
        package_mod $hostname $type $soft_name
    fi
    ;;
    "service")      #bash ot-scm.sh -h <hostname> <type> <service_name>
    if (( ${#} != 4 )) 
    then
        echo "Incorrect number of arguments. Please refer to arg_help"
        exit 
    fi
    shift
    shift
    hostname=$1
    shift
    type=$1
    shift
    soft_name=$1
    if [ "$(grep -w ${hostname} inventory.txt)" == "" ] 
    then
        echo "Host not present"
    else
        service_mod $hostname $type $soft_name
    fi
    ;;
    "copy")     #bash ot-scm.sh -h <hostname1> local-src/remote-src <src path> local-src/remote-src <src path> -h <hostname2>
   
    if (( ${#} != 8 || ${#} != 6 )) 
    then
        echo "Incorrect number of arguments. Please refer to arg_help"
        exit 
    fi
   
    shift
    shift
    hostname1=$1
    shift
    typeofsrc1=$1
    shift
    path1=$1
    shift
    typeofsrc2=$1
    shift
    path2=$1
    shift
    shift
    hostname2=$1

    if [ "$typeofsrc1" == "local-src" ] && [ "$typeofsrc2" == "remote-src" ]
    then
        typeofcp="lr"
        if [ "$(grep -w ${hostname1} inventory.txt)" == "" ] 
        then
            echo "Host not present"
        else
            fetch_mod $hostname1 $typeofsrc1 $path1 $typeofsrc2 $path2 $typeofcp
        fi
    elif [ "$typeofsrc1" == "remote-src" ] && [ "$typeofsrc2" == "remote-src" ] 
    then
        if [ "$(grep -w ${hostname1} inventory.txt)" == "" ] || [ "$(grep -w ${hostname2} inventory.txt)" == "" ]  
        then
            echo "Host not present"
        else
            copy_mod $hostname1 $hostname2 $typeofsrc1 $path1 $typeofsrc2 $path2
        fi
    elif [ "$typeofsrc1" == "remote-src" ] && [ "$typeofsrc2" == "local-src" ] 
    then
        typeofcp="rl"
        if [ "$(grep -w ${hostname1} inventory.txt)" == "" ] 
        then
            echo "Host not present"
        else
            fetch_mod $hostname1 $typeofsrc1 $path1 $typeofsrc2 $path2 $typeofcp
        fi
    fi
    ;;
    "template")     #bash ot-scm.sh template -h <hostname> <template_path> remote-src <remote_src_dest> vars:<var1=value1,var2=value2...>
    
    if (( ${#} != 7 )) 
    then
        echo "Incorrect number of arguments. Please refer to arg_help"
        exit 
    fi
    
    shift
    shift
    hostname=$1
    shift
    templatepath=$1
    shift
    shift
    remote_src_dest=$1
    shift
    vars=$1
    if [ "$(grep -w ${hostname} inventory.txt)" == "" ] || [ "$vars" == "" ] 
    then
        echo "Wrong input"
    else
        template_mod $hostname $templatepath $remote_src_dest $vars
    fi
    ;;
    "edit")     #bash ot-scm.sh edit "<datatoadd>" remote-src <destination> -h <hostname>

    if (( ${#} != 5 )) 
    then
        echo "Incorrect number of arguments. Please refer to arg_help"
        exit 
    fi

    shift
    datatoadd=$1
    shift
    shift
    destination=$1
    shift
    shift
    hostname=$1
    if [ "$(grep -w ${hostname} inventory.txt)" == "" ] 
    then
        echo "Host not present"
    else
        edit_mod "$datatoadd" $destination $hostname
    fi
    ;;
    "arg_help")
    arg_help
    ;;
    *)
    echo "Please enter a module or type ot-scm.sh arg_help to get info"
    ;;
esac
    