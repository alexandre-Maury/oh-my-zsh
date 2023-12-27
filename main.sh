#!/usr/bin/env bash

#==============================================================================================================
#
# Auteur  : Alexandre Maury 
# Version 1.2
# License : GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007
# Faire une modification du clonage dans /temp/
#==============================================================================================================

deps=("zsh" "npm" "git" "curl" "sudo" "neofetch" "fonts-powerline")

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

# Sauvegarde des fichier de base 
printf "%s \\n" "[En cours] Sauvegarde du fichier .zshrc"
sudo cp -rf /root/.zshrc /root/.zshrc-backup-$(date +"%Y-%m-%d")
sudo cp -rf /home/"${utilisateur}"/.zshrc /home/"${utilisateur}"/.zshrc-backup-$(date +"%Y-%m-%d")

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
git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git /tmp/zsh/oh-my-zsh
sudo cp -rf /tmp/zsh/oh-my-zsh /root/.oh-my-zsh
sudo cp -rf /root/.oh-my-zsh/templates/zshrc.zsh-template /root/.zshrc

# Install themes (powerlevel10k)
printf "%s %s \\n" "[En cours] Installation du theme" "==> powerlevel10k"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /tmp/zsh/powerlevel10k
sudo cp -rf /tmp/zsh/powerlevel10k /root/.oh-my-zsh/custom/themes/powerlevel10k


# Install plugins (zsh-autosuggestions - zsh-syntax-highlighting -zsh-completions) 
plugins=("zsh-autosuggestions" "zsh-syntax-highlighting" "zsh-completions")
for plugin in "${plugins[@]}"; do
    printf "%s %s \\n" "[En cours] Installation du plugin" "==> ${plugin}"
    git clone --depth=1 https://github.com/zsh-users/"${plugin}".git /tmp/zsh/${plugin}
    sudo cp -rf /tmp/zsh/${plugin} /root/.oh-my-zsh/custom/plugins/"${plugin}" 
done

# Installer fzf
printf "%s \\n" "[En cours] Installation de fzf" # A tester
git clone --depth=1 https://github.com/junegunn/fzf.git /tmp/zsh/fzf
sudo cp -rf /tmp/zsh/fzf /root/.oh-my-zsh/custom/plugins/fzf
yes | sudo /root/.oh-my-zsh/custom/plugins/fzf/install
                
# Activation du theme 
printf "%s %s \\n" "[En cours] Activation du theme" "==> powerlevel10k"
sudo sed  -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' /root/.zshrc

# Activation des plugins (zsh-autosuggestions et zsh-syntax-highlighting)
printf "%s %s \\n" "[En cours] Activation des plugins" "==> zsh-autosuggestions et zsh-syntax-highlighting"
sudo sed  -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)/g' /root/.zshrc

# Copie des fichier dans le dossier utilisateur
printf "%s %s \\n" "[En cours] Copie des fichier" "==> /home/${utilisateur}"
sudo cp -rf /root/.oh-my-zsh /home/"${utilisateur}"/.oh-my-zsh
sudo cp -rf /root/.zshrc /home/"${utilisateur}"/.zshrc 

sudo chown -R ${utilisateur}:${utilisateur} /home/${utilisateur}/.oh-my-zsh /home/${utilisateur}/.zshrc

echo 'export VISUAL=vim' >> /root/.zshrc


printf "%s %s\n" "[Succès] Installation terminée" "==> Redémarrer le terminal - puis procéder à sa configuration"

