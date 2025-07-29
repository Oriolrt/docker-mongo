#!/bin/bash
# Script to add a user to Linux system

username=student
password=student

# UID i GID per defecte si no es passen via entorn
groupname=mongodb
USER_ID=${HOST_UID:-1000}

# El GID correspon al del grup mongodb que cal canviar si es passen via entorn
GROUP_ID=${HOST_GID:-999}

echo "id usuari: $USER_ID, id grup: $GROUP_ID"

if [ $(id -u) -eq 0 ]; then
  # Check if the group '${groupname}' exists
  if getent group ${groupname} > /dev/null 2>&1; then
    echo "El grup '${groupname}' ja existeix."
  else
    # si no existeix donem el mateix que ${username}
    groupname=${username}
  fi

  egrep "^$username" /etc/passwd >/dev/null

  if [ $? -eq 0 ]; then
	  OLD_UID=$(id -u ${username})
	  OLD_GID=$(id -g ${groupname})
	  groupmod -g ${GROUP_ID} ${groupname}
	  usermod -u  ${USER_ID} -g ${GROUP_ID} ${username}

	  find / -user $OLD_UID -exec chown -h ${username} {} \; 2>/dev/null
	  find / -group $OLD_GID -exec chgrp -h ${groupname} {} \; 2>/dev/null


	  echo "$username exists! changing password."
	  echo ${username}:${password} | chpasswd
	  exit 0
  else
    # Crear grup si no existeix
    if ! getent group "$GROUP_ID" >/dev/null; then
      groupadd -g "$GROUP_ID" "$groupname"
    fi

    
    # Crear usuari amb UID/GID i directori home
    useradd -m -u "$USER_ID" -g "$GROUP_ID" -s /bin/bash "$username"
    echo "${username}:${password}" | chpasswd
 
    [ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
  fi

  #afegim l'usuari al grup de ${groupname}

  # Add the user '${username}' to the group '${groupname}'
  echo "Afegint l'usuari '${username}' al grup '${groupname}'..."
  sudo usermod -aG ${groupname} ${username}
  
else
  echo "Only root may add a user to the system"
  exit 2
fi

