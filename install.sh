#!/usr/bin/env bash

while [ $# -gt 0 ]; do
  case "$1" in
    --target*|-t*)
      if [[ "$1" != *=* ]]; then shift; fi # Value is next arg if no `=`
      target="${1#*=}"
      ;;
    --flake*|-f*)
      if [[ "$1" != *=* ]]; then shift; fi
      flake="${1#*=}"
      ;;
    --user*|-u*)
      if [[ "$1" != *=* ]]; then shift; fi
      user="${1#*=}"
      ;;
    --help|-h)
      echo "--help -h: print this message"
      echo "--target -t: set the target system to install on"
      echo "--flake -f: set the flake to install on the target system"
      echo "--user -u: set the user to install flake as on the target system"
      exit 0
      ;;
    *)
      echo "Error: Invalid argument $1"
      exit 1
      ;;
  esac
  shift
done

if [ -z ${target} ]; then
	echo "target is blank";
	exit 1;
fi

if [ -z ${flake} ]; then
	echo "flake is blank";
	exit 1;
fi

temp=$(mktemp -d)
# Function to cleanup temporary directory on exit
cleanup() {
  rm -rf "$temp"
}
trap cleanup EXIT

# copy key file to temp folder to copy over to target
mkdir -p $temp$AGE_KEY_FILE_LOCATION
cp -r $AGE_KEY_FILE_LOCATION/* $temp$AGE_KEY_FILE_LOCATION

# commit number in this is because the main branch of nixos-anywhere is broken right now
nix run github:nix-community/nixos-anywhere/b3b6bfebba35d55fba485ceda588984dec74c54f -- --extra-files $temp --flake ".#$flake" ${user:-nixos}@$target