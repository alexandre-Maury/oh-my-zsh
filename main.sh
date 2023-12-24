#!/usr/bin/env bash

#==============================================================================================================
#
# Auteur  : Alexandre Maury 
# Version 1.1
# License : GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
#==============================================================================================================

deps=("npm" "git" "curl")

if [[ $EUID != 0 ]]; then
    printf "\n"
    printf "%s\\n" "[-] privilèges root obligatoire ==> sudo su"
    exit 1
fi

apt update -y > >(tee /dev/null) 2>&1
apt upgrade -y > >(tee /dev/null) 2>&1
apt full-upgrade -y > >(tee /dev/null) 2>&1
apt autoremove -y > >(tee /dev/null) 2>&1


for dep in "${deps[@]}"; do
    if apt list --installed 2>/dev/null | grep -q "^$dep/"; then
        printf "==> %s %s\\n" "$dep :" "Déjà installé"
    else
        printf "[*] %s ==> %s\\n" "Installation :" "$dep"
        apt install -y "$dep" || {
            printf "[-] %s ==> %s\\n" "Echec de l'installation :" "$dep"
            exit 1
        }
        printf "[*] %s ==> %s\\n" "Installation reussi:" "$dep"
    fi
done




