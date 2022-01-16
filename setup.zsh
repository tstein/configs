#!/bin/zsh

CONFIGS=`dirname $0`
cd $CONFIGS
git submodule update --init --recursive

mkdir -p ~/.config/nvim
mkdir -p ~/.local/{bin,tmp}

ln -ns "$CONFIGS/bin/mtmux" ~/.local/bin/mtmux
ln -ns "$CONFIGS/dir_colors" ~/.dir_colors
ln -ns "$CONFIGS/nvim/init.vim" ~/.config/nvim/init.vim
ln -ns "$CONFIGS/tmux.conf" ~/.tmux.conf
ln -ns "$CONFIGS/vim" ~/.vim
ln -ns "$CONFIGS/vimrc" ~/.vimrc
ln -ns "$CONFIGS/zsh" ~/.zsh
ln -ns "$CONFIGS/zshrc" ~/.zshrc
if [[ "$USER" == "ted" ]]; then
    ln -ns "$CONFIGS/gitconfig" ~/.gitconfig
else
    print "skipping gitconfig because you may not be ted"
fi

vim +BundleInstall +qa
if [ which nvim >/dev/null 2>/dev/null ]; then
  nvim +PlugInstall
fi

exec zsh
