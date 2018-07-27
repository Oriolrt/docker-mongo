#!/bin/bash
# Script to add a user to Linux system

username=student
password=student

if [ $(id -u) -eq 0 ]; then
  egrep "^$username" /etc/passwd >/dev/null

  if [ $? -eq 0 ]; then
	  echo "$username exists! changing password."
	  echo "${username}:${password}" | passwd &> /dev/null
	  exit 0
  else
	useradd -m -p ${password} $username -s /bin/bash

	[ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
 fi
else
  echo "Only root may add a user to the system"
  exit 2
fi

