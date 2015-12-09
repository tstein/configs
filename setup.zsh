#!/bin/zsh

CONFIGS=`pwd`
cd ~
ln -s "$CONFIGS/dir_colors" .dir_colors
ln -s "$CONFIGS/gitconfig" .gitconfig
ln -s "$CONFIGS/tmux.conf" .tmux.conf
ln -s "$CONFIGS/vim" .vim
ln -s "$CONFIGS/vimrc" .vimrc
ln -s "$CONFIGS/zsh" .zsh
ln -s "$CONFIGS/zshrc" .zshrc

cd $CONFIGS
git submodule init
git submodule update
vim +BundleInstall +qa

exec zsh
