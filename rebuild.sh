#!/usr/bin/env bash

sudo nixos-rebuild ${1:-switch} --flake .#$(hostname)