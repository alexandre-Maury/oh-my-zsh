#!/usr/bin/env bash

#==============================================================================================================
#
# Auteur  : Alexandre Maury 
# Version 1.2
# License : GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Faire une modification du clonage dans /temp/
#==============================================================================================================

deps=("npm" "git" "curl" "sudo" "neofetch" "fonts-powerline")

read -p "[*] Veuillez entrer votre nom d'utilisateur : " utilisateur


# Validation du nom d'utilisateur
if [ -z "$utilisateur" ]; then
    printf "%s \\n" "[Erreur] Nom d'utilisateur vide. Veuillez entrer un nom d'utilisateur valide. "
    exit 1
fi

# Check les paquets installé et procéde à l'installation de ceux manquants
for dep in "${deps[@]}"; do
    if sudo apt list --installed 2>/dev/null | grep -q "^$dep/"; then
        printf "%s %s \\n" "==> $dep :" "Déjà installé"
    else
        printf "%s %s \\n" "[*] Installation :" "==> $dep"
        sudo apt install -y "$dep" || {
            printf "%s %s \\n" "[Erreur] lors de l'installation :" "==> $dep"
            exit 1
        }
        printf "%s %s \\n" "[Succès] installation" "==> $dep"
    fi
done

# Créer le dossier de sauvegarde
printf "%s \\n" "[En cours] création du dossier de sauvegarde"
mkdir -p /home/"${utilisateur}"/.config/zsh/save 

# Sauvegarde des fichier de base 
printf "%s \\n" "[En cours] Sauvegarde du fichier .zshrc"
cp -rf /home/"${utilisateur}"/.zshrc /home/"${utilisateur}"/.config/zsh/save/.zshrc-backup-$(date +"%Y-%m-%d")


# Vérifier si le shell actuel est déjà zsh
if [ "$(basename "$SHELL")" != "zsh" ]; then
    # Changer le shell de l'utilisateur à zsh
    sudo chsh -s $(which zsh) && echo $SHELL
    printf "%s %s \\n" "[Succès] Shell configuré" "==> $SHELL"
else
    printf "%s %s \\n" "[Succès] Le shell est déjà configuré" "==> $SHELL"

fi

# Install oh-my-zsh
printf "%s \\n" "[En cours] Installation de my-oh-zsh"
export ZSH="/home/${utilisateur}/.config/zsh/oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"


# Install themes (powerlevel10k)
printf "%s %s \\n" "[En cours] Installation du theme" "==> powerlevel10k"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-/home/"${utilisateur}"/.config/zsh/oh-my-zsh/custom}/themes/powerlevel10k


# Install plugins (zsh-autosuggestions and zsh-syntax-highlighting)
plugins=("zsh-autosuggestions" "zsh-syntax-highlighting")
for plugin in "${plugins[@]}"; do
    printf "%s %s \\n" "[En cours] Installation du plugin" "==> ${plugin}"
    git clone https://github.com/zsh-users/"${plugin}".git ${ZSH_CUSTOM:-/home/"${utilisateur}"/.config/zsh/oh-my-zsh/custom}/plugins/"${plugin}"
done

# Installer fzf
printf "%s \\n" "[En cours] Installation de fzf"
git clone https://github.com/junegunn/fzf.git /home/"${utilisateur}"/.config/fzf
yes | /home/"${utilisateur}"/.config/fzf/install
                
# Activation du theme 
printf "%s %s \\n" "[En cours] Activation du theme" "==> powerlevel10k"
sed  -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' /home/"${utilisateur}"/.zshrc

# Activation des plugins (zsh-autosuggestions et zsh-syntax-highlighting)
printf "%s %s \\n" "[En cours] Activation des plugins" "==> zsh-autosuggestions et zsh-syntax-highlighting"
sed  -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' /home/"${utilisateur}"/.zshrc
                
# Copie des fichier dans le dossier ${utilisateur}
# cp -rf $HOME/.config/zsh/oh-my-zsh /home/"${utilisateur}"/.config/zsh
# cp -rf $HOME/.zshrc /home/"${utilisateur}"/.zshrc
