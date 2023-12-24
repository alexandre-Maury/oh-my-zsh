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




















