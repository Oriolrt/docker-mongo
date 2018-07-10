#!/bin/bash
# Script to add a user to Linux system

username=student
password=student

if [ $(id -u) -eq 0 ]; then
#  read -p "Enter username : " username
#  read -s -p "Enter password : " password
  egrep "^$username" /etc/passwd >/dev/null
  pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)

  if [ $? -eq 0 ]; then
	echo "$username exists! changing password."
	echo "${username}:${pass}" | passwd &> /dev/null
	exit 0
  else
	useradd -m -p $pass $username -s /bin/bash

	[ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
 fi
else
  echo "Only root may add a user to the system"
  exit 2
fi

