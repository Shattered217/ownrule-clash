#!/bin/bash
# Ubuntu 20.04 FTP One-Click Setup Script
# Purpose: Install and configure vsftpd, allow manual username and password input.

# Ensure the script is run with root or sudo privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run the script with root or sudo privileges."
  exit 1
fi

echo "====== Starting FTP setup script ======"

# Step 1: Update system and install vsftpd
echo "Updating system and installing vsftpd..."
apt update && apt install -y vsftpd

# Step 2: Backup and configure vsftpd
echo "Backing up and configuring vsftpd..."
cp /etc/vsftpd.conf /etc/vsftpd.conf.bak

cat > /etc/vsftpd.conf <<EOF
# vsftpd configuration file
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

# Step 3: Allow manual username and password input
read -p "Enter FTP username (default: ftpuser): " FTP_USER
FTP_USER=${FTP_USER:-ftpuser}  # Default to 'ftpuser' if no username is entered

read -s -p "Enter FTP user password: " FTP_PASSWORD
echo  # New line
read -s -p "Re-enter FTP user password: " FTP_PASSWORD_CONFIRM
echo

# Verify passwords match
if [ "$FTP_PASSWORD" != "$FTP_PASSWORD_CONFIRM" ]; then
  echo "Passwords do not match. Please re-run the script and ensure they match."
  exit 1
fi

FTP_HOME="/home/$FTP_USER/ftp"

# Create FTP user
echo "Creating FTP user: $FTP_USER"
useradd -m -d $FTP_HOME -s /usr/sbin/nologin $FTP_USER
echo -e "$FTP_PASSWORD\n$FTP_PASSWORD" | passwd $FTP_USER

# Set directory permissions
echo "Setting user directory permissions..."
mkdir -p $FTP_HOME
chown nobody:nogroup $FTP_HOME
chmod a-w $FTP_HOME

# Create upload directory
UPLOAD_DIR="$FTP_HOME/upload"
mkdir -p $UPLOAD_DIR
chown $FTP_USER:$FTP_USER $UPLOAD_DIR
chmod 755 $UPLOAD_DIR

# Step 4: Restart vsftpd service and enable on boot
echo "Restarting vsftpd service..."
systemctl restart vsftpd
systemctl enable vsftpd

# Display setup details
echo "====== Setup Completed ======"
echo "FTP User: $FTP_USER"
echo "FTP Password: Set"
echo "FTP Home Directory: $FTP_HOME"
echo "FTP Upload Directory: $UPLOAD_DIR"
echo "Please use an FTP client to connect and test (use your server's IP or domain)."

exit 0
