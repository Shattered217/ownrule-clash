#!/bin/bash
# Ubuntu 20.04 FTP 一键配置脚本
# 功能：安装并配置 vsftpd，手动输入用户名和密码。

# 确保以 root 或 sudo 权限运行
if [ "$EUID" -ne 0 ]; then
  echo "请使用 root 用户或加 sudo 执行脚本"
  exit 1
fi

echo "====== 开始一键配置 FTP 服务 ======"

# 第一步：更新系统并安装 vsftpd
echo "正在更新系统并安装 vsftpd..."
apt update && apt install -y vsftpd

# 第二步：备份并配置 vsftpd
echo "正在备份并配置 vsftpd..."
cp /etc/vsftpd.conf /etc/vsftpd.conf.bak

cat > /etc/vsftpd.conf <<EOF
# vsftpd 配置文件
listen=YES
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
allow_writeable_chroot=YES
pasv_enable=YES
pasv_min_port=40000
pasv_max_port=45000
listen_port=21
ssl_enable=NO
EOF

# 第三步：手动输入 FTP 用户名和密码
read -p "请输入 FTP 用户名（默认: ftpuser）： " FTP_USER
FTP_USER=${FTP_USER:-ftpuser}  # 如果未输入用户名，使用默认值 ftpuser

read -s -p "请输入 FTP 用户密码： " FTP_PASSWORD
echo  # 换行
read -s -p "请再次输入 FTP 用户密码： " FTP_PASSWORD_CONFIRM
echo

# 验证密码输入一致
if [ "$FTP_PASSWORD" != "$FTP_PASSWORD_CONFIRM" ]; then
  echo "两次密码输入不一致，请重新运行脚本并确保输入一致。"
  exit 1
fi

FTP_HOME="/home/$FTP_USER/ftp"

# 创建 FTP 用户
echo "正在创建 FTP 用户：$FTP_USER"
useradd -m -d $FTP_HOME -s /usr/sbin/nologin $FTP_USER
echo -e "$FTP_PASSWORD\n$FTP_PASSWORD" | passwd $FTP_USER

# 设置用户目录权限
echo "正在设置用户目录权限..."
mkdir -p $FTP_HOME
chown nobody:nogroup $FTP_HOME
chmod a-w $FTP_HOME

# 创建上传目录
UPLOAD_DIR="$FTP_HOME/upload"
mkdir -p $UPLOAD_DIR
chown $FTP_USER:$FTP_USER $UPLOAD_DIR
chmod 755 $UPLOAD_DIR

# 第四步：重启服务并设置开机自启
echo "正在重启 vsftpd 服务..."
systemctl restart vsftpd
systemctl enable vsftpd

# 显示配置信息
echo "====== 配置完成 ======"
echo "FTP 用户：$FTP_USER"
echo "FTP 密码：已设置"
echo "FTP 主目录：$FTP_HOME"
echo "FTP 上传目录：$UPLOAD_DIR"

exit 0
