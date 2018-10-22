#!/bin/bash
set -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
CONF=$HOME/.vimrc
BundleDIR=$HOME/.vim/bundle
VundleDIR=$BundleDIR/Vundle.vim

if [ -f /etc/lsb-release ]; then
  __Distro=$(lsb_release -a 2>/dev/null |awk 'FNR == 1 {print}' |awk '/Distributor ID:/{print $3}')
  if [ "${__Distro}" = "Ubuntu" ]; then
    source "${DIR}/install/install.ubuntu.sh"
  elif [ "${__Distro}" = "Debian" ]; then
    source "${DIR}/install/install.debian.sh"
  else
    echo "Invalid Debian variant [${__Distro}]"
    exit 1
  fi
elif [ -f /etc/debian_release ]; then
  source "${DIR}/install/install.debian.sh"
elif [ -f /etc/arch-release ]; then
  source "${DIR}/install/install.arch.sh"
else
  echo "Unsupported distro"
  exit 1
fi

check-deps () {
  #Check dependencies for supported distros \
  #python-dev \
  if [ "${__Distro}" = "Ubuntu" ]; then
    dpkg-query -W --showformat='${Status}\n' python-dev 2>&1 |grep 'install ok installed' || true
    if [ "" == "$PKG_OK" ]; then
      echo "No python-dev installed"
      sudo apt-get --yes install python-dev
    fi
  fi
}

linkrc () {
  if [ -f $CONF ]; then
    if [ ! -L $CONF ]; then
      rm $CONF
      ln -s $DIR/.vimrc $CONF
    fi
  else
    ln -s $DIR/.vimrc $CONF
  fi
}

install-vundle () {
  if [ -d $VundleDIR/.git ]; then
    pushd $VundleDIR
    git pull
    popd
  else
    git clone https://github.com/VundleVim/Vundle.vim.git $VundleDIR
  fi
}

install-bundle () {
  vim +BundleInstall +qall
}

install-ycm () {
  YcmDir="${BundleDIR}/YouCompleteMe"

  YcmBuildTmp=$(mktemp -d)

  pushd "${YcmDir}"
    git submodule update --init --recursive
  popd

  ensure-clang

  pushd "${YcmBuildTmp}"

    cmake -G "Unix Makefiles" \
      "$(clang-path)" \
      -DUSE_PYTHON2=OFF \
      . "${YcmDir}/third_party/ycmd/cpp"

    cmake --build . --target ycm_core --config Release
  popd

  if hash go 2>/dev/null; then
    pushd "${YcmDir}/third_party/ycmd/third_party/gocode"
      go build
    popd
  fi

  if hash npm 2>/dev/null; then
    pushd "${YcmDir}/third_party/ycmd/third_party/tern_runtime"
      npm install --production
    popd
  fi

  #rm -rf ${ClangTmp} # TODO: Uncomment when actually working!
}

install-extras () {
  source "${DIR}/extras/*.sh"
}

conf-tern () {
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
}

check-deps

linkrc
install-vundle
install-bundle
install-ycm

