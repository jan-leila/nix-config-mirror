# Hosts

## Host Map
|   Hostname  |      Device Description    |   Primary User   |    Role   |
| :---------: | :------------------------: | :--------------: | :-------: |
|  `twilight` |      Desktop Computer      |      Leyla       |  Desktop  |
|  `horizon`  |  13 inch Framework Laptop  |      Leyla       |  Laptop   |
|  `defiant`  |         NAS Server         |      Leyla       |  Service  |
|  `emergent` |      Desktop Computer      |       Eve        |  Laptop   |
| `threshold` |           Laptop           |       Eve        |  Desktop  |


### Rebuild current machine to match target host:
`sudo nixos-rebuild switch --flake .#hostname`

### Rebuild current machine maintaining current target
`./rebuild.sh`

# New machine setup
keys for decrypting password secrets for each users located at `/var/lib/sops-nix/key.txt`

updating passwords: `sops secrets/secrets.yaml`

`nix run github:nix-community/nixos-anywhere/69ad3f4a50cfb711048f54013404762c9a8e201e -- --flake '.#hostname' nixos@192.168.1.130 --extra-files ~/.config/sops/age/`

> how the current config was set up https://www.youtube.com/watch?v=G5f6GC7SnhU

> something about ssh keys for remotes

# Notes:
- Look into this for fixing nixos-anywhere `https://github.com/lucidph3nx/nixos-config/tree/main`
- Look into this for rotating sops keys `https://technotim.live/posts/rotate-sops-encryption-keys/`
- Look into this for openssh known configurations https://search.nixos.org/options?channel=unstable&from=0&size=15&sort=alpha_asc&type=packages&query=services.openssh
- Look into this for flake templates https://nix.dev/manual/nix/2.22/command-ref/new-cli/nix3-flake-init

# Updating
`nix flake update`

# Tasks:

## Tech Debt
- allowUnfree should be dynamically enabled by the users whenever they need them (this isnt enabled at all right now for some reason???)
- GNOME default monitors per hardware configuration?
- graphics driver things should prob be in the hardware-configuration.nix
- use dashes for options not camel case
- Move configs for pipe mouse, open rgb, and via keyboard to hardware config and install users side from those configs
## New Features
- DISKO for server
- STOP FROM SLEEPING
- VS code extensions should be installed declaratively
- Flake templates
- Install all the things on the NAS
- firefox declarative???
- figure out steam vr things?
- Open GL?
- util functions
- openssh known hosts
- limit boot configurations to 2 on defiant
- rotate sops encryption keys