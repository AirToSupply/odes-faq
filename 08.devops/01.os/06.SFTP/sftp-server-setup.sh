#!/bin/bash

# -----------------------------------------
# local sftp server configuration
# -----------------------------------------
# sftp user group
SFTP_GROUP=mlops
# sftp user
SFTP_USER="sftpadmin"
# sftp password
SFTP_PASS="sftpadmin@123"
# sftp storage root directory
SFTP_STORAGE_ROOT_DIR=/home/sftp
# sftp target config file location
SSHD_CONFIG_FILE=/etc/ssh/sshd_config
# sftp config parameter
SFTP_CONFIG=$(cat <<EOF
Match User $SFTP_USER
      ChrootDirectory $SFTP_STORAGE_ROOT_DIR
      ForceCommand internal-sftp
      AllowTcpForwarding no
      X11Forwarding no
EOF
)

SFTP_OTHER_CONFIG=$(cat <<EOF


# ChangTianML SFTP Server start
$SFTP_CONFIG
# ChangTianML SFTP Server end
EOF
)

# create sftp usergroup
if grep -q -E "^$SFTP_GROUP:" /etc/group; then
    echo "User Group ($SFTP_GROUP) has been already existed."
else
    sudo groupadd $SFTP_GROUP
fi

# create sftp user
if grep -q -E "^$SFTP_USER:" /etc/passwd; then
    echo "User ($SFTP_USER) has been already existed."
else
    sudo useradd -m $SFTP_USER -s /sbin/nologin -g $SFTP_GROUP
    echo "${SFTP_USER}:${SFTP_PASS}" | sudo chpasswd
fi

# create sftp storage directory
if [ ! -d "$SFTP_STORAGE_ROOT_DIR" ]; then
    sudo mkdir -p "$SFTP_STORAGE_ROOT_DIR"
    sudo mkdir -p $SFTP_STORAGE_ROOT_DIR/{data,etc,home,opt,root,tmp,usr,var,run}
    sudo chown root:$SFTP_GROUP $SFTP_STORAGE_ROOT_DIR
    sudo chmod 755 $SFTP_STORAGE_ROOT_DIR
    sudo chown $SFTP_USER:$SFTP_GROUP $SFTP_STORAGE_ROOT_DIR/{data,etc,home,opt,root,tmp,usr,var,run}
    sudo chmod 755 $SFTP_STORAGE_ROOT_DIR/{data,etc,home,opt,root,tmp,usr,var,run}
else
    echo "sftp storage directory has been already existed."
fi


# [conf] remove `Subsystem sftp /usr/lib/openssh/sftp-server`
sub_sys_sftp_server_tag_pattern="^Subsystem\s+sftp\s+/usr/lib/openssh/sftp-server\s*$"
finding=`grep -E "$sub_sys_sftp_server_tag_pattern" "$SSHD_CONFIG_FILE"`
if [[ -n $finding ]]; then
    sudo sed -i 's/^Subsystem\s*sftp\s*\/usr\/lib\/openssh\/sftp-server/#&/' "$SSHD_CONFIG_FILE"
fi

# [conf] add `Subsystem sftp internal-sftp`
sub_sys_intl_sftp="Subsystem sftp internal-sftp"
sub_sys_intl_sftp_pattern="^Subsystem\s+sftp\s+internal-sftp\s*$"
sub_sys_intl_sftp_tag_pattern="# override default of no subsystems"
if grep -q -E "$sub_sys_intl_sftp_pattern" "$SSHD_CONFIG_FILE"; then
    echo "Subsystem sftp internal-sftp has been exists."
else
    sudo sed -i "/$sub_sys_intl_sftp_tag_pattern/a $sub_sys_intl_sftp" "$SSHD_CONFIG_FILE"
fi

# add sftp other config
SFTP_CONFIG_START_TAG="^#\s+ChangTianML\s+SFTP\s+Server\s+start\s*$"
SFTP_CONFIG_END_TAG="^#\s+ChangTianML\s+SFTP\s+Server\s+end\s*$"
if grep -q -E "$SFTP_CONFIG_START_TAG" $SSHD_CONFIG_FILE && grep -q -E "$SFTP_CONFIG_END_TAG" $SSHD_CONFIG_FILE; then
    echo "update sftp server config"
    sudo sed -i '/^# ChangTianML SFTP Server start/,/^# ChangTianML SFTP Server end/{/^# ChangTianML SFTP Server start/!{/^# ChangTianML SFTP Server end/!d}}' "$SSHD_CONFIG_FILE"
    sudo echo "$SFTP_CONFIG" > /tmp/changtianml_sftp.conf
    sudo sed -i "/^# ChangTianML SFTP Server start/r /tmp/changtianml_sftp.conf" "$SSHD_CONFIG_FILE"
    sudo rm -rf /tmp/changtianml_sftp.conf
else
    echo "append sftp server config"
    sudo echo "$SFTP_OTHER_CONFIG" > /tmp/changtianml_sftp.conf
    sudo sed -i "$ r /tmp/changtianml_sftp.conf" "$SSHD_CONFIG_FILE"
    sudo rm -rf /tmp/changtianml_sftp.conf
fi

# restart sshd server
sudo systemctl restart sshd && sudo systemctl status sshd