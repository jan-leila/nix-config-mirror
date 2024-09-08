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
keys for decrypting password secrets for each users located at ~/.config/sops/age/keys.txt

updating passwords: `sops secrets/secrets.yaml`

TODO: keys.txt should prob be readable by owning user only?

> how the current config was set up https://www.youtube.com/watch?v=G5f6GC7SnhU

> look into this? `https://technotim.live/posts/rotate-sops-encryption-keys/`

> something about ssh keys for remotes

# Tasks:

## Tech Debt
- allowUnfree should be dynamically enabled by the users whenever they need them
- GNOME default monitors per hardware configuration?
- graphics driver things should prob be in the hardware-configuration.nix
- what does `boot.kernelModules = [ "sg" ]` do?
- sops.age.keyFile should not just be hard coded to leyla?
- use dashes for options not camel case
## New Features
- RAID CARD
- VS code extensions should be installed declaratively
- Flake templates - https://nix.dev/manual/nix/2.22/command-ref/new-cli/nix3-flake-init
- Install all the things on the NAS
- firefox declarative???
- figure out steam vr things?
- Open GL?
- util functions
- openssh known hosts https://search.nixos.org/options?channel=unstable&from=0&size=15&sort=alpha_asc&type=packages&query=services.openssh
- limit boot configurations to 2 on defiant