#!/bin/bash
set -e

DIR="$(dirname "${BASH_SOURCE[0]}")"

source "${DIR}/common/env.sh"

if hash go 2>/dev/null; then
  print-title "Installing gotags for Tagbar"

  print-progress "Creating temp"
  GoTmp="$(mktemp -d)"

  print-progress "go get -u github.com/jstemmer/gotags"
  GOPATH="${GoTmp}" go get -u github.com/jstemmer/gotags

  print-progress "Copying binaries"
  cp -r "${GoTmp}/bin/gotags" "${ExtraBinDir}/"

  print-progress "Cleaning up"
  rm -rf "${GoTmp}/src"
  rm -rf "${GoTmp}/bin"
  rmdir "${GoTmp}"

  print-done
fi
