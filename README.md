# nix-config

https://git.jan-leila.com/jan-leila/nix-config

nix multi user, multi system, configuration with `sops` secret management, `home-manager`, and `nixos-anywhere` setup via `disko` with `zfs` + `impermanence`

# Hosts

## Host Map
|   Hostname  |      Device Description    |   Primary User   |    Role   |
| :---------: | :------------------------: | :--------------: | :-------: |
|  `twilight` |      Desktop Computer      |      Leyla       |  Desktop  |
|  `horizon`  |  13 inch Framework Laptop  |      Leyla       |  Laptop   |
|  `defiant`  |         NAS Server         |      Leyla       |   Server  |
| `hesperium` |             Mac            |      ?????       |    ???    |
|  `emergent` |      Desktop Computer      |       Eve        |  Desktop  |
| `threshold` |           Laptop           |       Eve        |  Laptop   |
|  `wolfram`  |         Steam Deck         |      House       |  Handheld |
|   `ceder`   | A5 Tablet (not using nix)  |      Leyla       |   Tablet  |
|   `skate`   | A6 Tablet (not using nix)  |      Leyla       |   Tablet  |
|   `shale`   | A6 Tablet (not using nix)  |       Eve        |   Tablet  |
|   `coven`   |  Pixel 8 (not using nix)   |      Leyla       |  Android  |

# Tooling
## Rebuilding
`./rebuild.sh`

## Updating
`nix flake update`

## New host setup
`./install.sh --target 192.168.1.130 --flake hostname`

## Updating Secrets
`sops -c sops secrets/secrets_file_here.yaml`

## Inspecting a configuration
`nix-inspect -p .`

# Notes:

## Research topics
- Look into this for auto rotating sops keys `https://technotim.live/posts/rotate-sops-encryption-keys/`
- Look into this for openssh known configurations https://search.nixos.org/options?channel=unstable&from=0&size=15&sort=alpha_asc&type=packages&query=services.openssh
- Look into this for flake templates https://nix.dev/manual/nix/2.22/command-ref/new-cli/nix3-flake-init
- Look into this for headscale https://carlosvaz.com/posts/setting-up-headscale-on-nixos/
- https://nixos-and-flakes.thiscute.world/

# Tasks:

## Tech Debt
- monitor configuration in `~/.config/monitors.xml` should be sym linked to `/run/gdm/.config/monitors.xml` (https://www.reddit.com/r/NixOS/comments/u09cz9/home_manager_create_my_own_symlinks_automatically/)
- move applications in `defiant/services.nix` into their own modules
- syncthing password
## New Features
- offline access for nfs mounts (overlay with rsync might be a good option here? https://www.spinics.net/lists/linux-unionfs/msg07105.html note about nfs4 and overlay fs)
- Flake templates - we need to add these to some kind of local registry??? `nix flake show templates` - https://nix.dev/manual/nix/2.18/command-ref/new-cli/nix3-flake-init
- samba mounts
- figure out steam vr things?
- Open GL?
- openssh known hosts
- rotate sops encryption keys periodically (and somehow sync between devices?)
- zfs email after scrubbing
- tail scale clients
- wake on LAN for updates
- ISO target that contains authorized keys for nixos-anywhere https://github.com/diegofariasm/yggdrasil/blob/4acc43ebc7bcbf2e41376d14268e382007e94d78/hosts/bootstrap/default.nix
- Immich
- zfs encryption FIDO2 2fa