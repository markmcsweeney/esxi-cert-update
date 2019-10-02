#!/bin/bash

#########################################################################
#
# 2019.10.02
#
# This script compares the local cert start date with the main cert
# start date. If the main cert is newer, it is copied to the ESXi
# cert store and services.sh is reloaded. Tested working on ESXi 5.5 and 6.0
#
# LetsEncrypt is assumed to have been installed on cert generation server.
#
# If /var/log/cert/renew does not exist, create it manually. Will look how
# to force creation later.
#
# NOTE: systemd is assumed. Change accordingly if sysV is used.
# NOTE: script also assumes Apache, if different change accordingly.
#
#########################################################################

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
   scp -i /root/.keys/"$ESXI"_rsa -p /etc/letsencrypt/live/"$ESXI"."$DOMAINNAME"/fullchain.pem root@"$IP":/etc/vmware/ssl/rui.crt | \
   scp -i /root/.keys/"$ESXI"_rsa -p /etc/letsencrypt/live/"$ESXI"."$DOMAINNAME"/privkey.pem root@"$IP":/etc/vmware/ssl/rui.key | \
   ssh -i .keys/"$ESXI"_rsa root@"$IP" 'services.sh restart' > /dev/null 2>&1 | \
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