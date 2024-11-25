#!/bin/bash
# by helpme_ls
# 2024.6.26
# 用途：一键搭建ftp，省去一大堆b事
# 第一步，安装ftp
apt-get -y install vsftpd
# 第二步，更改配置文件
mv /etc/vsftpd.conf /etc/vsftpd.confbak
echo """anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
pasv_enable=YES
pasv_min_port=8000
pasv_max_port=8050
chroot_local_user=yes
chroot_list_enable=yes
chroot_list_file=/etc/vsftpd/chroot_list
allow_writeable_chroot=YES
listen_port=21
reverse_lookup_enable=NO
pam_service_name=vsftpd
userlist_enable=YES
tcp_wrappers=YES
allow_writeable_chroot=YES
chmod_enable=YES
""" > /etc/vsftpd.conf
systemctl restart vsftpd
 
grep "/sbin/nologin" /etc/shells || echo "/sbin/nologin" >> /etc/shells
