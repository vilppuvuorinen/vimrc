#!/bin/bash
set -e

ClangVersion="3.8.0"
DebianVersion=$(lsb_release -a 2>/dev/null|awk '/Release:/{ print $2 }'|awk -F. '{ print $1 }')

ClangTmp=$(mktemp -d)
ClangPkg="clang+llvm-${ClangVersion}-x86_64-linux-gnu-debian${DebianVersion}.tar.xz"
ClangUrl="http://llvm.org/releases/${ClangVersion}/${ClangPkg}.tar.xz"

check-pkg () {
  if [ $# -ne 1 ]; then
    exit 1
  fi

  __pkg=$1
  dpkg -s "${__pkg}"
}

check-deps () {
  check-pkg python-dev
  check-pkg python3-dev
  check-pkg cmake
}

ensure-clang () {
  pushd "${ClangTmp}"
    curl -SLO "${ClangUrl}"
    tar -xf "${ClangPkg}.tar.xz"
    rm "${ClangPkg}.tar.xz"
  popd
}

clang-path () {
  echo "-DPATH_TO_LLVM_ROOT=./${ClangTmp}/$ClangPkg}"
}

