#!/bin/zsh

CONFIGS=`pwd`
cd ~
ln -s "$CONFIGS/dir_colors" .dir_colors
ln -s "$CONFIGS/tmux.conf" .tmux.conf
ln -s "$CONFIGS/vim" .vim
ln -s "$CONFIGS/vimrc" .vimrc
ln -s "$CONFIGS/zsh" .zsh
ln -s "$CONFIGS/zshrc" .zshrc
if [[ "$USER" == "ted" ]]; then
    ln -s "$CONFIGS/gitconfig" .gitconfig
else
    print "you may not be ted. skipping gitconfig."
fi

mkdir -p ~/.local/bin
# vim expects this to exist
mkdir -p ~/.local/tmp

mkdir -p ~/.config/nvim ~/.local/share/nvim/site/pack
ln -s "$CONFIGS/nvim/init.vim" ~/.config/nvim/init.vim
ln -s "$CONFIGS/nvim/plugins" ~/.local/share/nvim/site/pack/plugins

ln -s "$CONFIGS/bin/mtmux" ~/.local/bin/

cd $CONFIGS
git submodule update --init --recursive
vim +BundleInstall +qa

exec zsh
