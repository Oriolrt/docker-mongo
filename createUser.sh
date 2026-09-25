#!/bin/bash
# Script to add a user to Linux system

username=student
password=${STUDENT_PASSWORD:-student}

# UID i GID per defecte si no es passen via entorn
USER_ID=${HOST_UID:-1000}
GROUP_ID=${HOST_GID:-999}

echo "id usuari: $USER_ID, id grup: $GROUP_ID"

if [ $(id -u) -ne 0 ]; then
  echo "Only root may add a user to the system"
  exit 2
fi

# Reutilitza el grup amb el GID demanat si ja existeix (p.ex. "mongodb"),
# sense renombrar-lo (groupmod deixaria orfes els usuaris de sistema que
# ja apunten al seu GID original). Si no existeix, en crea un de nou.
if getent group "${GROUP_ID}" > /dev/null 2>&1; then
  groupname=$(getent group "${GROUP_ID}" | cut -d: -f1)
else
  groupname=${username}
  groupadd -g "${GROUP_ID}" "${groupname}"
fi

if egrep "^${username}:" /etc/passwd > /dev/null 2>&1; then
  OLD_UID=$(id -u ${username})
  OLD_GID=$(id -g ${username})

  usermod -u "${USER_ID}" -g "${GROUP_ID}" "${username}"

  # Realinea la propietat dels fitxers de l'usuari només a les carpetes
  # on pot tenir contingut (evita un find / complet a cada arrencada).
  #
  # "-exec ... +" i NO "-exec ... \;": amb "\;" find engega un procés chown/chgrp NOU PER
  # CADA FITXER. Amb /data (dades reals de Mongo) i /home/student (que inclou el JupyterLab
  # instal·lat amb --user, desenes de milers de fitxers), això són desenes de milers de
  # forks per contenidor -- i multiplicat pels contenidors que arrenquen alhora en un node,
  # trigava més dels 600s que setup.sh (check_ssh_owner_and_setup) espera que /home/student
  # passi a ser propietat de HOST_UID, deixant el SSH sense contrasenya sense configurar per
  # a tots els grups. Amb "+" find agrupa tots els fitxers en poques crides.
  echo "Realineant propietat de fitxers (${OLD_UID}:${OLD_GID} -> ${USER_ID}:${GROUP_ID})..."
  for dir in /data /home/student; do
    [ -d "$dir" ] || continue
    find "$dir" -user "${OLD_UID}" -exec chown -h "${username}" {} + 2>/dev/null
    find "$dir" -group "${OLD_GID}" -exec chgrp -h "${groupname}" {} + 2>/dev/null
  done
  echo "Propietat realineada."

  echo "$username exists! changing password."
  echo "${username}:${password}" | chpasswd
else
  useradd -m -u "${USER_ID}" -g "${GROUP_ID}" -s /bin/bash "${username}"
  echo "${username}:${password}" | chpasswd

  [ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
fi

# Afegim l'usuari al grup de ${groupname}
echo "Afegint l'usuari '${username}' al grup '${groupname}'..."
usermod -aG "${groupname}" "${username}"
