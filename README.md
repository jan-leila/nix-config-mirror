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
- This person seams to know what they are doing with home manager https://github.com/arvigeus/nixos-config/

## Configuration
set up git configuration for local development: `git config core.hooksPath .hooks`

to update passwords run: `nix shell nixpkgs#sops -c sops secrets/user-passwords.yaml` (NOTE: this depends on the SOPS_AGE_KEY_DIRECTORY environment variable being set)

# Tasks:

## Tech Debt
- join config for systemd.tmpfiles.rules and service directory bindings
- monitor configuration in `~/.config/monitors.xml` should be sym linked to `/run/gdm/.config/monitors.xml` (https://www.reddit.com/r/NixOS/comments/u09cz9/home_manager_create_my_own_symlinks_automatically/)
- move applications in server environment into their own flakes
- get rid of disko config and import it in hardware-configuration.nix
- why does users.users.<name>.home conflict with home-manager.users.<name>.home.homeDirectory
## New Features
- offline access for nfs mounts (overlay with rsync might be a good option here? https://www.spinics.net/lists/linux-unionfs/msg07105.html note about nfs4 and overlay fs)
- Flake templates
- searxng
- nextcloud ???
- samba mounts
- firefox declarative???
- figure out steam vr things?
- Open GL?
- util functions
- openssh known hosts
- rotate sops encryption keys periodically (and somehow sync between devices?)
- zfs email after scrubbing
- headscale server (just needs to be tested)
- mastodon server
- tail scale clients
- wake on LAN
- ISO target that contains authorized keys for nixos-anywhere