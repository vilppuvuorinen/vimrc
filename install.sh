#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
CONF=$HOME/.vimrc
BundleDIR=$HOME/.vim/bundle
VundleDIR=$BundleDIR/Vundle.vim

function linkrc () {
  ln -s $DIR/.vimrc $CONF
}

if [ -f $CONF ]; then
  if [ ! -L $CONF ]; then
    rm $CONF
    linkrc
  fi
else
  linkrc
fi

if [ -d $VundleDIR/.git ]; then
  cd $VundleDIR; git pull
else
  git clone https://github.com/gmarik/Vundle.vim.git $VundleDIR
fi

cd $BundleDIR/tern_for_vim; npm install
cat <<EOF > ~/.tern-config
{
  "libs": [
    "browser",
    ""
  ],
  "loadEagerly": [
  ],
  "plugins": {
  }
}
EOF
