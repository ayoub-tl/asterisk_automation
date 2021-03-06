#!/usr/bin/env bash
automation_file=$(pwd)
apt update
add-apt-repository universe
#install dependicies
apt -y install git curl wget libnewt-dev libedit-dev libssl-dev libncurses5-dev subversion libsqlite3-dev build-essential libjansson-dev libxml2-dev  uuid-dev
cd ~
wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-18-current.tar.gz
tar xvf asterisk-18-current.tar.gz
file=$(ls  | grep asterisk.* | grep -v '.tar.gz')
cd $file
#load the configuration of the machine
./configure --with-jansson-bundled
#compile the configuration
make
#install
make install
#load the  /etc/asterisk with sample config
make samples
make config

cd ~/$file/contrib/init.d
#creat a inint.d/asterisk file to launch the service
cp rc.debian.asterisk /etc/init.d/asterisk
#REPLACE THE PLACEHOLDER IN THE CONFIG
BFILE=$(type asterisk | awk '{ print $3 }' )
sed -i "s|__ASTERISK_SBIN_DIR__\/asterisk|$BFILE|g" /etc/init.d/asterisk
sed -i "s/__ASTERISK_VARRUN_DIR__/\/var\/lib\/asterisk/g" /etc/init.d/asterisk
sed -i "s/__ASTERISK_ETC_DIR__/\/etc\/asterisk/g" /etc/init.d/asterisk
#change asterick to run as user asterisk
useradd -d /var/lib/asterisk  asterisk
chown -R asterisk  /var/spool/asterisk /var/lib/asterisk /var/run/asterisk


cd ~/$file/contrib/init.d/
cp etc_default_asterisk /etc/default/asterisk
#uncmommnet the user field
sed -i "s/;AST_USER/AST_USER/g" /etc/default/asterisk
sed -i "s/;AST_GROUP/AST_USER/g" /etc/default/asterisk
update-rc.d asterisk defaults



#install dhcp
apt install -y dhcpd

sed -i "s/DHCPD_ENABLED=\"no\"/DHCPD_ENABLED=\"yes\"/g" /etc/default/udhcpd


sed -i 's/.*start.*/start       192.168.1.40 /g' /etc/udhcpd.conf
sed -i 's/.*end.*/end       192.168.1.49 /g' /etc/udhcpd.conf
#configure dns & getway
sed -i 's/opt[[:space:]]*dns.*/opt   dns     8.8.8.8/g' /etc/udhcpd.conf
sed -i 's/opt[[:space:]]*router.*/opt   router     192.168.1.1/g' /etc/udhcpd.conf
sed -i '/option[[:space:]]*dns/d' /etc/udhcpd.conf
sed -i '/opt[[:space:]]*wins/d' /etc/udhcpd.conf

#instlall ntp
apt install -y ntp 
/etc/init.d/ntp start 


cd /etc/asterisk
cp sip.conf sip.conf.org

#remove comment 
sed -i '/^[[:space:]]*;/d' sip.conf
#remove emplty line 
sed -i '/^[[:space:]]*$/d' sip.conf
sed -i '/^$/d' sip.conf
#add qualify=yes to genral cintext
sed -i '9iqualify=yes' sip.conf

#copy the document +empty the config file
cp extensions.conf extensions.conf.copy
echo '' > extensions.conf

#create user and alias aka extension
$automation_file/create_user.sh user1 password2 alias1
$automation_file/create_user.sh user2 password2 alais2




/etc/init.d/asterisk reload
/etc/init.d/asterisk stop
/etc/init.d/asterisk start
