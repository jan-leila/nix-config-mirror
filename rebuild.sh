#!/usr/bin/env bash

if [ -d "result" ];
then
  preserve_result=true
else
  preserve_result=false
fi

show_trace=false

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
    --mode*|-m*)
      if [[ "$1" != *=* ]]; then shift; fi
      mode="${1#*=}"
      ;;
    --user*|-u*)
      if [[ "$1" != *=* ]]; then shift; fi
      user="${1#*=}"
      ;;
    --host*)
      if [[ "$1" != *=* ]]; then shift; fi
      host="${1#*=}"
      ;;
    --preserve-result)
      preserve_result=true
      ;;
    --no-preserve-result)
      preserve_result=false
      ;;
    --show-trace)
      show_trace=true
      ;;
    --help|-h)
      echo "--help -h: print this message"
      echo "--target -t: set the target system to rebuild on"
      echo "--flake -f: set the flake to rebuild on the target system"
      echo "--mode -m: set the mode to rebuild flake as on the target system"
      echo "--user -u: set the user to rebuild flake as on the target system"
      echo "--host: set the host that the flake will be rebuilt on (unset for current machine)"
      echo "--preserve-result: do not remove the generated result folder after building"
      echo "--no-preserve-result: remove any result folder after building"
      echo "--show-trace: show trace on builds"
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
user=${user:-$USER}

command="nixos-rebuild $mode --use-remote-sudo --flake .#$flake"

if [[ $host ]];
then
  command="$command --build-host $host"
fi

if [[ "$target" != "$(hostname)" ]];
then
	command="$command --target-host $user@$target"
fi

if [[ "$show_trace" = true ]];
then
	command="$command --show-trace"
fi

echo $command
$command

if [ -d "result" ];
then
  if [[ "$preserve_result" == "false" ]];
  then
    rm -r result
  fi
fi