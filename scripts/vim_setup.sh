#!/bin/bash

#Installation de Vim 
brew install vim


#Ajout des configuration dans le fichier de configuration de vim
(
echo "set number"
echo "set smartindent"
echo "set autoindent"
echo "set ruler"
echo "set mouse=a"
echo "syntax on"
echo "colorscheme Tomorrow-Night"
echo "set t_Co=256"
)>~/.vimrc

#Création de dossier pour le theme
mkdir -p ~/.vim/colors


#Téléchargement du thème
wget https://raw.githubusercontent.com/chriskempson/tomorrow-theme/master/vim/colors/Tomorrow-Night.vim -O ~/.vim/colors/Tomorrow-Night.vim

#reload de vimrc

source ~/.vimrc
