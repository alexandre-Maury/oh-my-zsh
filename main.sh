#!/usr/bin/env bash

#==============================================================================================================
#
# Auteur  : Alexandre Maury 
# Version 1.2
# License : GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
#==============================================================================================================

deps=("npm" "git" "curl" "sudo" "neofetch")

if [[ $EUID != 0 ]]; then
    printf "\n"
    printf "%s %s \\n" "[Erreur] Privilèges root nécessaires" "==> sudo su | su - "
    exit 1
else
    sleep 1
    echo "[*] Veuillez entrer votre nom d'utilisateur : "
    read utilisateur

    # Validation du nom d'utilisateur
    if [ -z "$utilisateur" ]; then
        printf "%s \\n" "[Erreur] Nom d'utilisateur vide. Veuillez entrer un nom d'utilisateur valide. "
        exit 1
    fi

    # Le reste du script ici ...
    apt update -y 
    apt upgrade -y 
    apt full-upgrade -y 
    apt autoremove -y 
    clear

    # Check les paquets installé et procéde à l'installation de ceux manquants
    for dep in "${deps[@]}"; do
        if apt list --installed 2>/dev/null | grep -q "^$dep/"; then
            printf "%s %s \\n" "==> $dep :" "Déjà installé"
        else
            printf "%s %s \\n" "[*] Installation :" "==> $dep"
            apt install -y "$dep" || {
                printf "%s %s \\n" "[Erreur] lors de l'installation :" "==> $dep"
                exit 1
            }
            printf "%s %s \\n" "[Succès] installation" "==> $dep"
        fi
    done

    # Accorde les droits administrateur a l'utilisateur ci celui-ci le souhaite
    echo "[*] Accorder les privilèges sudo au compte ${$utilisateur} ==> y/N  "
    read reponse
    if [ "$reponse" == "y" ]; then
        usermod -aG sudo $utilisateur
        printf "%s \\n" "[Succès] Votre compte ${$utilisateur} est à présent membre du groupe sudo"
    fi

    # Configure les identifiants git ci celui-ci le souhaite
    echo "[*] Souhaitez-vous configurer Git ==> y/N  "
    read git
    if [ $git = 'y' ]; then
        read -p "==> Entrez votre nom d'utilisateur : " name
        read -p "==> Entrez votre adresse email : " email	
        git config --global user.name "${name}"
        git config --global user.email "${email}"
        
        printf "%s \\n" "[Succès] Vos identifiants git sont configurés"
    fi

    # Configure les drivers video
    echo "[*] Souhaitez-vous configurer le pilotte video ==> y/N "
    read driver
    if [ $driver = 'y' ]; then

        nvidia=$(lspci | grep -e VGA -e 3D | grep -ie nvidia 2> /dev/null || echo '')
        amd_ati=$(lspci | grep -e VGA -e 3D | grep -e ATI -e AMD 2> /dev/null || echo '')
        intel=$(lspci | grep -e VGA -e 3D | grep -i intel 2> /dev/null || echo '')

        if [ -n "$nvidia" ]; then
            apt install xserver-xorg-video-nouveau -y    
        elif [ -n "$amd_ati" ]; then
            apt install xserver-xorg-video-ati -y  
        elif [ -n "$intel" ]; then
            apt install xserver-xorg-video-intel -y
            
        else
            apt install xserver-xorg-video-vesa -y
        
        fi
        
        printf "%s \\n" "[Succès] Votre driver est configuré"
    fi


    # Configure le shell a zsh et install oh-my-zsh
    echo "[*] Souhaitez-vous installé oh-my-zsh ==> y/N "
    read zsh
    if [[ "$zsh" =~ ^[Yy]$ ]]; then

        # Vérifier si le shell actuel est déjà zsh
        if [ "$(basename "$SHELL")" != "zsh" ]; then
            # Changer le shell de l'utilisateur à zsh
            sudo usermod -s "$(which zsh)" "$utilisateur"
        else
            printf "Le shell est déjà configuré comme zsh."
        fi

        # Cloner oh-my-zsh
        git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git /home/"$utilisateur"/.config/oh-my-zsh/

        # Cloner et déplacer le thème Bullet Train
        git clone --depth=1 https://github.com/caiogondim/bullet-train.zsh.git /tmp/bullet-train.zsh
        mv /tmp/bullet-train.zsh /home/"$utilisateur"/.config/oh-my-zsh/themes/

        # Cloner les plugins
        plugins=("zsh-autosuggestions" "zsh-syntax-highlighting")
        for plugin in "${plugins[@]}"; do
            git clone --depth=1 "https://github.com/zsh-users/$plugin" "/home/$utilisateur/.config/oh-my-zsh/plugins/$plugin"
        done

        # Installer fzf
        git clone --depth 1 https://github.com/junegunn/fzf.git /home/"$utilisateur"/.config/fzf
        yes | /home/"$utilisateur"/.config/fzf/install

        printf "%s \\n" "[Succès] oh-my-zsh est configuré"
    fi

    printf "%s \\n" "[Configuration] ==> modification de vim"
    curl -L https://raw.githubusercontent.com/alexandre-Maury/vimrc/master/install.sh | bash
    printf "%s \\n" "[Succés] ==> modification de vim"

    printf "%s \\n" "[Configuration] ==> transfert des fonds d'ecrans"
    cp -a $PWD/backgrounds /home/${utilisateur}/
     printf "%s \\n" "[Succés] ==> disponible dans /home/${utilisateur}/"


fi
