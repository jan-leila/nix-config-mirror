#!/usr/bin/env bash

while [ $# -gt 0 ]; do
  case "$1" in
    --target*|-t*)
      if [[ "$1" != *=* ]]; then shift; fi # Value is next arg if no `=`
      target="${1#*=}"
      ;;
    --flake*|-h*)
      if [[ "$1" != *=* ]]; then shift; fi
      flake="${1#*=}"
      ;;
    --mode*|-m*)
      if [[ "$1" != *=* ]]; then shift; fi
      mode="${1#*=}"
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

target=${target:-$(hostname)}
flake=${flake:-$target}
mode=${mode:-switch}

if [[ "$target" == "$(hostname)" ]]
then
	sudo nixos-rebuild $mode --flake .#$flake
else
	nixos-rebuild $mode --use-remote-sudo --target-host $USER@$target --flake .#$flake
fi
