# esxi-cert-update

Bash script for Debian to compare the locally LetsEncrypt generated cert start date with the ESXi cert start date. If the local cert is newer than the ESXi cert, it is copied to the ESXi cert store and services.sh is reloaded. Tested working on ESXi 6.5 and greater.

This script compares the local cert start date with the main cert start date. If the main cert is newer, it is copied to the ESXi cert store and /etc/init.d/hostd is restarted. Tested working on ESXi 6.5 and greater. LetsEncrypt is assumed to have been installed on cert generation server. If /var/log/cert/renew does not exist, create it manually. 


To Do:

Look up how to check if /var/log/cert/renew exists and force creation if not there.
