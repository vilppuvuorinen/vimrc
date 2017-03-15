#!/bin/bash
set -e

ExtraBinDir="${HOME}/.vim/extra-bin"
mkdir -p "${ExtraBinDir}"

print-title () {
  echo "#############################################################"
  echo "# ${@}"
}

print-progress () {
  echo "> ${@}"
}

print-done () {
  echo "#############################################################"
  echo ""
}
