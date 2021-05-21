# AnsibleSimulatorUsingShellScript

Like ansible you need to create a custom tool which can be used to manage and configure remote instance.
1. User Module
This tool need to have a user module using which you can able to create a user, delete a user and modify it.
./ot-scm user create prashant -s /bin/bash
./ot-scm user delete prashant
./ot-scm user modify prashant -s /bin/nologin
2. File Module 
This module will be used to create, delete a file and directory, symbolic link etc.
./ot-scm file state=touch path=/opt/prashant owner=prashant group=adm
./ot-scm file state=absent path=/opt/prashant owner=prashant group=adm
./ot-scm file state=directory path=/opt/prashant 
./ot-scm file state=link path=/opt/prashant src=/home/opstree/new
./ot-scm file state=absent path=/opt/prashant 
3. Package Module
Add this module in your tool and it will be used to install packages in remote instance.
./ot-scm package install java-default
./ot-scm packge update
./ot-scm package remove nginx
4. Service Module
Add this module in your tool and it will be used to restart, start and stop a service.
./ot-scm service  enable nginx
./ot-scm service start nginx
./ot-scm service stop nginx
./ot-scm service restart nginx
5. Copy Module
Add this module in your tool and it will be used copy a file. 
[ from local to remote ]
[ from remote to remote ]
[ from remote to local ]
./ot-scm copy local-src pathofFile remote-src path ofFile
./ot-scm copy remote-src pathofFile remote-src path ofFile
./ot-scm copy remote-src pathofFile local-src path ofFile
6. Template Module
Add this module in your tool it will be used as a template to modify the file at run time
./ot-scm template pathtotemplatefile remote-src destination
7. Edit Module
./ot-scm edit "datatoadd" remote-src destination
You need to create a inventory file where you will define the remote info
You need to facilitate the grouping in inventory. 
i.e while calling group, all these module can run on all  member of group.
Try to execute module in different host parallelly
