#!/usr/bin/env bash
automation_file=$(pwd)
apt update
add-apt-repository universe
apt -y install git curl wget libnewt-dev libedit-dev libssl-dev libncurses5-dev subversion libsqlite3-dev build-essential libjansson-dev libxml2-dev  uuid-dev
cd ~
wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-18-current.tar.gz
tar xvf asterisk-18-current.tar.gz
file=$(ls  | grep asterisk.* | grep -v '.tar.gz')
cd $file

./configure --with-jansson-bundled

make

make install

make samples

make config

cd ~/asterisk-18.2.1/contrib/init.d

cp rc.debian.asterisk /etc/init.d/asterisk

BFILE=$(type asterisk | awk '{ print $3 }' )
sed -i "s|__ASTERISK_SBIN_DIR__\/asterisk|$BFILE|g" /etc/init.d/asterisk

sed -i "s/__ASTERISK_VARRUN_DIR__/\/var\/lib\/asterisk/g" /etc/init.d/asterisk

sed -i "s/__ASTERISK_ETC_DIR__/\/etc\/asterisk/g" /etc/init.d/asterisk

useradd -d /var/lib/asterisk  asterisk
chown -R asterisk  /var/spool/asterisk /var/lib/asterisk /var/run/asterisk

cd ~/$file/contrib/init.d/


cp etc_default_asterisk /etc/defualt/asterisk

sed -i "s/;AST_USER/AST_USER/g" /etc/default/asterisk
sed -i "s/;AST_GROUP/AST_USER/g" /etc/default/asterisk

update-rc.d asterisk defaults
#change the network to static
# /etc/netplan/00-installer-config.yaml
#******
#//
# file=$(ls /etc/netplan/)
# cat /etc/netplan/$file | grep -n dhcp | awk '{print $1}' | cut -c 1
# sed "s/dhcp4: true/dhcp4: false/"
# a$
#netplan apply


apt get install dhcpd
#vi /etc/default/udhcpd=> dhcp_enabled =yes
sed -i "s/DHCP_ENABLED=\"no\"/DHCP_ENABLED=\"yes\"/g"

#vi /etc/udhcpd.conf =>range
#*****
sed -i 's/.*start.*/start       192.168.1.40 /g' /etc/udhcpd.conf
sed -i 's/.*start.*/start       192.168.1.49 /g' /etc/udhcpd.conf
#**dns
sed -i 's/opt  dns.*/opt   dns     8.8.8.8/g' /etc/udhcpd.conf
sed -i 's/opt  router.*/opt   router     192.168.1.1/g' /etc/udhcpd.conf
sed -i '/option     dns/d' /etc/udhcpd.conf
sed -i '/option     wins/d' /etc/udhcpd.conf


apt install -y ntp 

/etc/init.d/ntp start 


cd /etc/asterisk
cp sip.conf sip.conf.org

#remove comment 
sed -i '/^[[:space:]]*;/d' sip.conf
#remove emplty line 
sed '/^[[:space:]]*$/d' sip.conf
#add qualify=yes to genral cintext
sed -i '9iqualify=yes' sip.conf

$automation_file/creat_sip_user.sh user1 password2 alias1
$automation_file./creat_sip_user.sh user2 password2 alais2



cp extensions.conf extensions.conf.copy
echo '' > extensions.conf

# cat <<EOF>> test

# [user]
# type=friend
# context=ulaw,alaw
# secret=12345678
# host=dynamic

# EOF

cp extensions.conf extensions.conf.copy
echo '' > extensions.conf

#done in create user
# cat <<EOF>> test

# [phones]
# exten =>100,1,NoOp('first dial')
# same => n,Dial(SIP/peer)
# same => n,Hangup
# EOF

/etc/init.d/asterisk stop
/etc/init.d/asterisk reload
/etc/init.d/asterisk start
