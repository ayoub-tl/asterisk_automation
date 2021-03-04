#!/usr/bin/env bash
 echo $1;
 echo $2;
 echo $3;
#etc/asterisk/sip.conf
cat <<EOT >> /etc/asterisk/sip.conf
[$1]
    type=friend
    context=phones
    allow=ulaw,alaw
    secret=$2
    host=dynamic

EOT



if grep -q phones  /tmp/test3; then
cat <<EOT >> /etc/extensions.conf
[phones]
 exten =>$3,1,NoOp('first dial')
 same => n,Dial(SIP/$1)
 same => n,Hangup

EOT

else
   cat <<EOT >> /etc/extensions.conf
 exten =>$3,1,NoOp('first dial')
 same => n,Dial(SIP/$1)
 same => n,Hangup

EOT
fi