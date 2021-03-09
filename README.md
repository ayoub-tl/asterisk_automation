asterisk.sh => file that download ,compile,configure asterisk,dhcp and ntp
create_user.sh=> register user with the alias and password => to call it (./create_user $username $alias $password)
vagrantfile=> to create a vm with virtual box and call asterisk.sh
ansible-playbook=> to cline this repo in remote device and call vagrantfile 
