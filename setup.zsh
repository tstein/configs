#!/bin/zsh

local -a skip_vims
zparseopts -skip_vims=skip_vims

CONFIGS=`dirname $(realpath -e $0)`
cd $CONFIGS
git submodule update --init --recursive

# dirs
mkdir -p ~/.config/nvim
mkdir -p ~/.local/{bin,tmp}

# symlinks
ln -ns "$CONFIGS/bin/mtmux" ~/.local/bin/mtmux
ln -ns "$CONFIGS/dir_colors" ~/.dir_colors
ln -ns "$CONFIGS/nvim/init.lua" ~/.config/nvim/init.lua
ln -ns "$CONFIGS/nvim/lua" ~/.config/nvim/lua
ln -ns "$CONFIGS/tmux.conf" ~/.tmux.conf
ln -ns "$CONFIGS/vim" ~/.vim
ln -ns "$CONFIGS/vimrc" ~/.vimrc
ln -ns "$CONFIGS/zsh" ~/.zsh
ln -ns "$CONFIGS/zshrc" ~/.zshrc

ln -ns "$CONFIGS/alacritty" ~/.config/alacritty
ln -ns "$CONFIGS/sway/sway" ~/.config/sway
ln -ns "$CONFIGS/sway/waybar" ~/.config/waybar
ln -ns "$CONFIGS/wsession" ~/.wsession
if [[ "$USER" == "ted" ]]; then
    ln -ns "$CONFIGS/gitconfig" ~/.gitconfig
else
    print "skipping gitconfig because you may not be ted"
fi

# ssh config
if [[ -e ~/.ssh/config ]]; then
  print "you have an existing .ssh/config. leaving it be."
else
  mkdir -p ~/.ssh
  cat >~/.ssh/config <<EOF
EnableEscapeCommandline yes

# only offer the default key by default
host *
  identitiesonly yes
  identityfile ~/.ssh/id_ed25519
  identityfile ~/.ssh/id_rsa

EOF
  print "created ~/.ssh/config."
fi

# vims
if [[ ! -n $skip_vims ]]; then
  vim +BundleInstall +qa
  if [ which nvim >/dev/null 2>/dev/null ]; then
    # packer is run automatically on first use
    nvim
  fi
fi

# go
exec zsh
