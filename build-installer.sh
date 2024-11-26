#!/usr/bin/env bash

while [ $# -gt 0 ]; do
  case "$1" in
    --flake*|-f*)
      if [[ "$1" != *=* ]]; then shift; fi
      flake="${1#*=}"
      ;;
    # --user*|-u*)
    #   if [[ "$1" != *=* ]]; then shift; fi
    #   user="${1#*=}"
    #   ;;
    --help|-h)
      echo "--help -h: print this message"
      echo "--flake -f: set the flake to build an installer for"
    #   echo "--user -u: set the user to install flake as on the target system"
      exit 0
      ;;
    *)
      echo "Error: Invalid argument $1"
      exit 1
      ;;
  esac
  shift
done

flake=${flake:-"basic"}
user=${user:-$USER}

nix build .#installerConfigurations.$flake.config.system.build.isoImage