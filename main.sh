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
    printf "%s\\n" "[-] privilèges root obligatoire ==> sudo su | su -"
    exit 1
else
    read -p "==> Entrez votre nom d'utilisateur : " utilisateur
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
            printf "[Erreur] %s ==> %s\\n" "Echec de l'installation :" "$dep"
            exit 1
        }
        printf "[Succès] %s ==> %s\\n" "Installation reussi:" "$dep"
    fi
done

# Accorde les droits administrateur a l'utilisateur ci celui-ci le souhaite
read -p "[*] Accorder les droits sudo ==> y/N " reponse
if [ "$reponse" == "y" ]; then
    usermod -aG sudo $utilisateur
    printf "[Succès] %s ==> %s\\n" "Votre compte est à présent membre du groupe sudo"
fi

# Configure les identifiants git ci celui-ci le souhaite
read -p "[*] Souhaitez-vous configurer Git ==> y/N " git
if [ $git = 'y' ]; then
    read -p "==> Entrez votre nom d'utilisateur : " name
    read -p "==> Entrez votre adresse email : " email	
	git config --global user.name "${name}"
	git config --global user.email "${email}"
	
    printf "[Succès] %s ==> %s\\n" "Vos identifiants git sont configurés"
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
	
    printf "[Succès] %s ==> %s\\n" "Votre driver est configuré"
fi


# Configure le shell a zsh et install oh-my-zsh
read -p "[*] Souhaitez-vous installé oh-my-zsh ==> y/N " zsh
if [[ "$zsh" =~ ^[Yy]$ ]]; then

    # Vérifier si le shell actuel est déjà zsh
    if [ "$(basename "$SHELL")" != "zsh" ]; then
        # Changer le shell de l'utilisateur à zsh
        sudo usermod -s "$(which zsh)" "$utilisateur"
    else
        printf "Le shell est déjà configuré comme zsh.\n"
    fi

    git clone git://github.com/robbyrussell/oh-my-zsh.git /home/${utilisateur}/.config/oh-my-zsh/

    # themes
    git clone https://github.com/caiogondim/bullet-train.zsh.git 
    mv bullet-train.zsh /home/${utilisateur}/.config/oh-my-zsh/themes/bullet-train
        
    # plugins
    git clone https://github.com/zsh-users/zsh-autosuggestions /home/${utilisateur}/.config/oh-my-zsh/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/${utilisateur}/.config/oh-my-zsh/plugins/zsh-syntax-highlighting
        
    git clone --depth 1 https://github.com/junegunn/fzf.git /home/${utilisateur}/.config/fzf
    yes | /home/${utilisateur}/.config/fzf/install

    printf "[Succès] %s ==> %s\\n" "oh-my-zsh est configuré"
fi

printf "[Configuration] %s ==> %s\\n" "modification de vim"
curl -L https://raw.githubusercontent.com/alexandre-Maury/vimrc/master/install.sh | bash
printf "[Succés] %s ==> %s\\n" "modification de vim"

printf "[Configuration] %s ==> %s\\n" "transfert des fonds d'ecrans"
cp -a $PWD/backgrounds /home/${utilisateur}/
printf "[Succés] %s ==> %s\\n" "disponible dans /home/${utilisateur}/"

















