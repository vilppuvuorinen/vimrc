#!/bin/bash
set -e

ClangVersion="3.8.0"
DebianVersion=$(lsb_release -a 2>/dev/null|awk '/Release:/{ print $2 }'|awk -F. '{ print $1 }')

check-pkg () {
  if [ $# -ne 1 ]; then
    exit 1
  fi

  __pkg=$1
  pacman -Q "${__pkg}"
}

check-deps () {
  check-pkg cmake
}

ensure-clang () {
  check-pkg clang
}

clang-path () {
  echo "-DUSE_SYSTEM_LIBCLANG=ON"
}

