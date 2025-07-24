#!/bin/bash
# Script to add a user to Linux system

username=student
password=student

# UID i GID per defecte si no es passen via entorn
USER_ID=${HOST_UID:-1000}
GROUP_ID=${HOST_GID:-1000}


if [ $(id -u) -eq 0 ]; then
  egrep "^$username" /etc/passwd >/dev/null


  if [ $? -eq 0 ]; then
	  echo "$username exists! changing password."
	  echo ${username}:${password} | chpasswd
	  exit 0
  else
    # Crear grup si no existeix
    if ! getent group "$GROUP_ID" >/dev/null; then
      groupadd -g "$GROUP_ID" "$username"
    fi

    
    # Crear usuari amb UID/GID i directori home
    useradd -m -u "$USER_ID" -g "$GROUP_ID" -s /bin/bash "$username"
    echo "${username}:${password}" | chpasswd
 
    [ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
 fi
else
  echo "Only root may add a user to the system"
  exit 2
fi

