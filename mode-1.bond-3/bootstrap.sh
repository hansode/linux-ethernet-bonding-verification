#!/bin/bash
#
# requires:
#  bash
#
set -e
set -x

function yum() {
  $(type -P yum) --disablerepo=updates "${@}"
}

# Add installation packages ...
addpkgs="
 bridge-utils
"

if [[ -n "$(echo ${addpkgs})" ]]; then
  yum install -y ${addpkgs}
fi