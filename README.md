# esxi-cert-update
Bash script to compare the locally LetsEncrypt generated cert start date with the ESXi cert start date. If the local cert is newer than the ESXi cert, it is copied to the ESXi cert store and services.sh is reloaded. Tested working on ESXi 5.5 and 6.0
