#!/bin/bash
set -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
CONF=$HOME/.vimrc
BundleDIR=$HOME/.vim/bundle
VundleDIR=$BundleDIR/Vundle.vim

ClangVersion="3.8.0"
UbuntuVersion=$(lsb_release -a 2>/dev/null|awk '/Release:/{ print $2 }')

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
    git clone https://github.com/gmarik/Vundle.vim.git $VundleDIR
  fi
}

install-bundle () {
  vim +BundleInstall +qall
}

check-pkg () {
  if [ $# -ne 1 ]; then
    exit 1
  fi

  __pkg=$1

  dpkg -s "${__pkg}"
}

install-ycm () {
  ClangPkg="clang+llvm-${ClangVersion}-x86_64-linux-gnu-ubuntu-${UbuntuVersion}"
  ClangUrl="http://llvm.org/releases/${ClangVersion}/${ClangPkg}.tar.xz"
  ClangTmp=$(mktemp -d)

  YcmDir="${BundleDIR}/YouCompleteMe"

  pushd "${YcmDir}"
    git submodule update --init --recursive
  popd

  pushd "${ClangTmp}"

    curl -SLO ${ClangUrl}
    tar -xf ${ClangPkg}.tar.xz
    rm ${ClangPkg}.tar.xz

    cmake -G "Unix Makefiles" \
      -DPATH_TO_LLVM_ROOT="./${ClangPkg}" \
      . "${YcmDir}/third_party/ycmd/cpp"

    cmake --build . --target ycm_core --config Release
  popd

  pushd "${YcmDir}/third_party/ycmd/third_party/gocode"
    go build
  popd

  pushd "${YcmDir}/third_party/ycmd/third_party/tern_runtime"
    npm install --production
  popd

  #rm -rf ${ClangTmp} # TODO: Uncomment when actually working!
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

check-pkg python-dev
check-pkg python3-dev
check-pkg cmake

linkrc
install-vundle
install-bundle
install-ycm

