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

## Configuration
updating passwords: `sops secrets/secrets.yaml`
set up git configuration for local development: `git config --local include.path .gitconfig`

# Tasks:

## Tech Debt
- allowUnfree should be enabled user side not host side (this isn't enabled at all right now for some reason???)
- move services from defiant into own flake
- made base domain in nas services configurable
- vscode extensions should be in own flake (make sure to add the nixpkgs.overlays in it too)
- server service system users should also be on local systems for file permission reasons
## New Features
- GNOME default monitors per hardware configuration?
- offline access for nfs mounts (overlay with rsync might be a good option here? https://www.spinics.net/lists/linux-unionfs/msg07105.html note about nfs4 and overlay fs)
- Flake templates
- Docker parity with existing NAS on defiant
- NFS on defiant
- firefox declarative???
- figure out steam vr things?
- Open GL?
- util functions
- openssh known hosts
- limit boot configurations to 2 on defiant
- rotate sops encryption keys periodically (and somehow sync between devices?)
- zfs email after scrubbing
- headscale server
- mastodon server
- tail scale clients
- wake on LAN