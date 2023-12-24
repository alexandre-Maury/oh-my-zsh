#!/bin/bash

#==============================================================================================================
#
# Auteur  : Alexandre Maury 
# Version 1.1
# License : GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
#==============================================================================================================

deps=("npm" "git" "curl" "sudo" "neofetch")

if [[ $EUID != 0 ]]; then
    printf "\n"
    printf "%s\\n" "[Erreur] Privilèges root nécessaires. Utilisez 'sudo' pour exécuter le script."
    exit 1
else
    echo "==> Veuillez entrer votre nom d'utilisateur : "
    read utilisateur

    # Validation du nom d'utilisateur
    if [ -z "$utilisateur" ]; then
        echo "[Erreur] Nom d'utilisateur vide. Veuillez entrer un nom d'utilisateur valide."
        exit 1
    fi

    # Le reste du script ici ...

fi





















