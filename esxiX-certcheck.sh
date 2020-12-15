#!/bin/bash

# Create variables for use in scripts

ESXI="SET ESXI HOSTNAME HERE" #ESXi hostname
IP="SET ESXI IP HERE" #ESXi IP
DOMAINNAME="SET DOMAIN NAME HERE" # Domain name
PATHTOSSHKEY="SET PAT TO SSH KEY HERE" # SSH key location

# Compare LetsEncrypt generated cert with cert present on ESXi host in question.

LOCALCERT="$(date -d "`openssl x509 -in /etc/letsencrypt/live/"$ESXI"."$DOMAINNAME"/fullchain.pem -noout -startdate | cut -c11-`" +%s)"
ESXICERT="$(date -d "`echo | openssl s_client -servername "$IP" -connect "$IP":443 2>/dev/null | openssl x509 -noout -startdate | cut -c11-`" +%s)"

if [ "$LOCALCERT" -eq "$ESXICERT" ]; then
  echo "Cert for $ESXI.$DOMAINNAME not due for renewal today "`date '+%Y-%m-%d'`' at '`date '+%R %Z'`"." >> /var/log/cert/renew.log

## Changed 'services.sh restart to only '/etc/init.d/hostd restart' due to error:
## "Invalid operation requested: This ruleset is required and cannot be disabled" on ESXi 6.5 and greater.

  else
   scp -i "$PATHTOSSHKEY" /etc/letsencrypt/live/"$ESXI"."$DOMAINNAME"/fullchain.pem root@"$IP":/etc/vmware/ssl/rui.crt | \
   scp -i "$PATHTOSSHKEY" -p /etc/letsencrypt/live/"$ESXI"."$DOMAINNAME"/privkey.pem root@"$IP":/etc/vmware/ssl/rui.key | \
   ##ssh -i "$PATHTOSSHKEY" root@"$IP" 'services.sh restart' > /dev/null 2>&1 | \
   ssh -i "$PATHTOSSHKEY" root@"$IP" '/etc/init.d/hostd restart' > /dev/null 2>&1 | \
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
