#!/usr/bin/env bash

#==============================================================================================================
#
# Auteur  : Alexandre Maury 
# Version 1.1
# License : GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
#==============================================================================================================

deps=("npm" "git" "curl" "sudo")

if [[ $EUID != 0 ]]; then
    printf "\n"
    printf "%s\\n" "[-] privilèges root obligatoire ==> sudo su | su -"
    exit 1
fi

# apt update -y 
# apt upgrade -y 
# apt full-upgrade -y 
# apt autoremove -y 

# Check les paquets installé et procéde à l'installation de ceux manquants
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

# Accorde les droits administrateur a l'utilisateur ci celui-ci le souhaite
read -p "[*] Accorder les droits sudo ==> y/N " reponse
if [ "$reponse" == "y" ]; then
    read -p "==> Entrez votre nom d'utilisateur : " user
    usermod -aG sudo $user
fi

# Configure les identifiants git ci celui-ci le souhaite
read -p "[*] Souhaitez-vous configurer Git ==> y/N " git
if [ $git = 'y' ]; then
    read -p "==> Entrez votre nom d'utilisateur : " name
    read -p "==> Entrez votre adresse email : " email	
	git config --global user.name "${name}"
	git config --global user.email "${email}"
	
    printf "[Succès] %s ==> %s\\n" "Votre compte est configuré"
fi








