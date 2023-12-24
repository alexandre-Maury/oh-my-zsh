#!/usr/bin/env bash

#==============================================================================================================
#
# Auteur  : Alexandre Maury 
# Version 1.1
# License : GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
#==============================================================================================================

deps=("npm" "git" "curl" "sudo" "neofetch")

if [[ $EUID != 0 ]]; then
    printf "\n"
    printf "%s\\n" "[Erreur] privilèges root obligatoire ==> sudo su | su -"
    exit 1
else
    read -p "==> Entrez votre nom d'utilisateur : " utilisateur
fi

apt update -y 
apt upgrade -y 
apt full-upgrade -y 
apt autoremove -y 
clear


# Check les paquets installé et procéde à l'installation de ceux manquants
for dep in "${deps[@]}"; do
    if apt list --installed 2>/dev/null | grep -q "^$dep/"; then
        printf "==> %s %s\\n" "$dep :" "Déjà installé"
    else
        printf "[*] %s ==> %s\\n" "Installation :" "$dep"
        apt install -y "$dep" || {
            printf "[Erreur] %s ==> %s\\n" "Echec de l'installation :" "$dep"
            exit 1
        }
        printf "[Succès] %s ==> %s\\n" "Installation reussi:" "$dep"
    fi
done

# Accorde les droits administrateur a l'utilisateur ci celui-ci le souhaite
read -p "[*] Accorder les droits sudo ==> y/N " reponse
if [ "$reponse" == "y" ]; then
    printf "[Succès] %s ==> %s\\n" "Votre compte est à présent membre du groupe sudo"
fi


















