#!/bin/bash

if [ "$#" -ne 1 ]; then
	echo "Usage: ./anonFinder.sh [network]"
	echo "Example: ./anonFinder.sh 192.168.1"
	exit
fi
ports="21,139,445,389,636"

for x in `seq 1 255`; do
  ip=$1.$x 
  echo " >> Starting "$ip
  nmap -p $ports $ip --script ftp-anon > "/tmp/nmapScan"
  
  # Check FTP Anon
  FTPexist=$(cat /tmp/nmapScan | grep "Anonymous FTP login allowed" | wc -l)
  if [[ $FTPexist == "1" ]]; then
  	echo " FTP Anonymous OK "$ip
  fi

  # Check SNMP Anon
  SNMPexist=$(cat /tmp/nmapScan | grep -E "139|445" | grep open | wc -l)
  if [[ $SNMPexist == "1" ]]; then
  	SNMPLog=$(smbclient \\\\$ip\\a "" 2>&1 | grep Domain | wc -l)
  	if [[ $SNMPLog == "1" ]]; then
  		echo " SNMP Anonymous OK "$ip
  	fi
  fi

  # Check LDAP Anon
  LDAPexist=$(cat /tmp/nmapScan | grep -E "389|636" | grep open | wc -l)
  if [[ $LDAPexist == "1" ]]; then
  	LDAPLog=$(ldapsearch -h 10.11.1.220 -p 139 2>&1 | grep -v "Can't contact" | wc -l)
  	if [[ $LDAPLog == "1" ]]; then
  		echo " LDAP Anonymous OK "$ip
  	fi
  	LDAPLog=$(ldapsearch -h 10.11.1.220 -p 636 2>&1 | grep -v "Can't contact" | wc -l)
  	if [[ $LDAPLog == "1" ]]; then
  		echo " LDAP Anonymous OK "$ip
  	fi
  fi



done 