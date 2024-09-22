# Hosts

## Host Map
|   Hostname  |      Device Description    |   Primary User   |    Role   |
| :---------: | :------------------------: | :--------------: | :-------: |
|  `twilight` |      Desktop Computer      |      Leyla       |  Desktop  |
|  `horizon`  |  13 inch Framework Laptop  |      Leyla       |  Laptop   |
|  `defiant`  |         NAS Server         |      Leyla       |  Service  |
|  `emergent` |      Desktop Computer      |       Eve        |  Laptop   |
| `threshold` |           Laptop           |       Eve        |  Desktop  |

# Tooling
## Lint
`./lint.sh`

## Rebuilding
`./rebuild.sh`

## Updating
`nix flake update`

## New host setup
`./install.sh --target 192.168.1.130 --flake hostname`

# Notes:

## Research topics
- Look into this for rotating sops keys `https://technotim.live/posts/rotate-sops-encryption-keys/`
- Look into this for openssh known configurations https://search.nixos.org/options?channel=unstable&from=0&size=15&sort=alpha_asc&type=packages&query=services.openssh
- Look into this for flake templates https://nix.dev/manual/nix/2.22/command-ref/new-cli/nix3-flake-init
- Look into this for headscale https://carlosvaz.com/posts/setting-up-headscale-on-nixos/
- Look into this for home assistant configuration https://nixos.wiki/wiki/Home_Assistant https://myme.no/posts/2021-11-25-nixos-home-assistant.html

## Configuration
updating passwords: `sops secrets/secrets.yaml`
set up git configuration for local development: `git config --local include.path .gitconfig`

# Tasks:

## Tech Debt
- allowUnfree should be enabled user side not host side (this isn't enabled at all right now for some reason???)
- vscode extensions should be in own flake (make sure to add the nixpkgs.overlays in it too)
- server service system users should also be on local systems for file permission reasons
- join config for systemd.tmpfiles.rules and service directory bindings
## New Features
- GNOME default monitors per hardware configuration? read this: https://discourse.nixos.org/t/gdm-monitor-configuration/6356/3
- offline access for nfs mounts (overlay with rsync might be a good option here? https://www.spinics.net/lists/linux-unionfs/msg07105.html note about nfs4 and overlay fs)
- fix pre commit hook
- Flake templates
- home assistant virtual machine
- pi hole docker
- searxng docker
- nextcloud ???
- samba mounts
- firefox declarative???
- figure out steam vr things?
- Open GL?
- util functions
- openssh known hosts
- rotate sops encryption keys periodically (and somehow sync between devices?)
- zfs email after scrubbing
- headscale server
- mastodon server
- tail scale clients
- wake on LAN