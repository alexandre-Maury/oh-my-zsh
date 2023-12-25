#!/usr/bin/env bash

#==============================================================================================================
#
# Auteur  : Alexandre Maury 
# Version 1.2
# License : GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Faire une modification du clonage dans /temp/
#==============================================================================================================

deps=("npm" "git" "curl" "sudo" "neofetch" "fonts-powerline")

if [[ $EUID != 0 ]]; then
    printf "\n"
    printf "%s %s \\n" "[Erreur] Privilèges root nécessaires" "==> sudo su | su - "
    exit 1
else
    read -p "[*] Veuillez entrer votre nom d'utilisateur : " utilisateur


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
    read -p "[*] Accorder les privilèges sudo au compte ${utilisateur} ==> y/N " reponse
    if [ "$reponse" == "y" ]; then
        usermod -aG sudo $utilisateur
        printf "%s \\n" "[Succès] Votre compte ${utilisateur} est à présent membre du groupe sudo"
    fi

    # Configure les identifiants git ci celui-ci le souhaite
    read -p "[*] Souhaitez-vous configurer Git ==> y/N " git
    if [ $git = 'y' ]; then
        read -p "==> Entrez votre nom d'utilisateur : " name
        read -p "==> Entrez votre adresse email : " email	
        git config --global user.name "${name}"
        git config --global user.email "${email}"
        
        printf "%s \\n" "[Succès] Vos identifiants git sont configurés"
    fi

    # Configure les drivers video
    read -p "[*] Souhaitez-vous configurer le pilotte video ==> y/N " driver
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
    read -p "[*] Souhaitez-vous installé le theme oh-my-zsh ==> y/N " zsh
    if [[ "$zsh" =~ ^[Yy]$ ]]; then

        mkdir -p $HOME/.config/zsh && mkdir -p /home/${utilisateur}/.config/zsh
        mkdir -p $HOME/.config/zsh/save && mkdir -p /home/${utilisateur}/.config/zsh/save

        # Vérifier si le shell actuel est déjà zsh
        if [ "$(basename "$SHELL")" != "zsh" ]; then
            # Changer le shell de l'utilisateur à zsh
            chsh -s $(which zsh) && echo $SHELL
        else
            printf "Le shell est déjà configuré comme $SHELL"
        fi

        printf "%s \\n" "==> Installation de oh-my-zsh ==> $HOME/.config/zsh/oh-my-zsh"
        export ZSH="$HOME/.config/zsh/oh-my-zsh"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"


        # Install themes (zsh-autosuggestions and zsh-syntax-highlighting)
        # git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.config/zsh/oh-my-zsh/custom}/themes/powerlevel10k
        themes=("powerlevel10k")
        for theme in "${themes[@]}"; do
            git clone https://github.com/zsh-users/${theme}.git ${ZSH_CUSTOM:-$HOME/.config/zsh/oh-my-zsh/custom}/themes/${theme}
        done

        # Install plugins (zsh-autosuggestions and zsh-syntax-highlighting)
        # git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-$HOME/.config/zsh/oh-my-zsh/custom}/plugins/zsh-autosuggestions 
        # git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.config/zsh/oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
        plugins=("zsh-autosuggestions" "zsh-syntax-highlighting")
        for plugin in "${plugins[@]}"; do
            git clone https://github.com/zsh-users/${plugin}.git ${ZSH_CUSTOM:-$HOME/.config/zsh/oh-my-zsh/custom}/plugins/${plugin}
        done

        # Installer fzf
        git clone https://github.com/junegunn/fzf.git /home/${utilisateur}/.fzf
        yes | /home/${utilisateur}/.fzf/install

        # Sauvegarde des fichier de base
        cp -rf /home/"${utilisateur}"/.zshrc /home/"${utilisateur}"/.config/zsh/save/.zshrc-backup-$(date +"%Y-%m-%d")
                
        # Activation du theme et des plugins
        sed  -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/g' $HOME/.zshrc
                
        # Copie des fichier dans le dossier ${utilisateur}
        cp -rf $HOME/.config/zsh/oh-my-zsh /home/"${utilisateur}"/.config/zsh
        cp -rf $HOME/.zshrc /home/"${utilisateur}"/.zshrc
        

    fi

fi
