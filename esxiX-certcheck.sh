#!/bin/bash

# Create variables for use in scripts

ESXI="SET ESXI HOSTNAME HERE" #ESXi hostname
IP="SET ESXI IP HERE" #ESXi IP
DOMAINNAME="SET DOMAIN NAME HERE" # Domain name


# Compare LetsEncrypt generated cert with cert present on ESXi host in question.

LOCALCERT=$(date -d "`openssl x509 -in /etc/letsencrypt/live/${ESXI}.$(DOMAINNAME)/fullchain.pem -noout -startdate | cut -c11-`" +%s)
ESXICERT=$(date -d "`echo | openssl s_client -servername ${IP} -connect ${IP}:443 2>/dev/null | openssl x509 -noout -startdate | cut -c11-`" +%s)

if [ "$LOCALCERT" == "$ESXICERT" ]; then
  echo "Cert for $ESXI not due for renewal today `date '+%Y-%m-%d'`." >> /var/log/cert/renew.log

  else
   scp -i PATHTOSSHKEY /etc/letsencrypt/live/"$ESXI"."$DOMAINNAME"/fullchain.pem root@"$IP":/etc/vmware/ssl/rui.crt | \
   scp -i PATHTOSSHKEY -p /etc/letsencrypt/live/"$ESXI"."$DOMAINNAME"/privkey.pem root@"$IP":/etc/vmware/ssl/rui.key | \
   ssh -i PATHTOSSHKEY root@"$IP" 'services.sh restart' > /dev/null 2>&1 | \
   echo "SSL Certificate for $ESXI.$DOMAINNAME was updated on "`date '+%Y-%m-%d'`' at '`date '+%R %Z'`'.' | \
   mail -s "SSL Certificate for $ESXI.$DOMAINNAME has been updated" SETEMAILHERE -aFrom:'SET FROM EMAIL NAME HERE<SETFROMEMAILHERE>'

fi

############################################################################
#
# This is a crontab entry that runs the script on Sunday and Thursday (0,4)
#
# 45 4 * * 0,4 /root/esxiX-certcheck.sh 2>/dev/null
#
#
# This is a crontab entry that runs the script every day
#
# 45 4 * * * /root/esxiX-certcheck.sh 2>/dev/null
#
############################################################################
