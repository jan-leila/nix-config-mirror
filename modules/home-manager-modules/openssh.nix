{
  pkgs,
  config,
  osConfig,
  lib,
  ...
}: {
  options.programs.openssh = {
    authorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
    hostKeys = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
      example = [
        {
          type = "rsa";
          bits = 4096;
          path = "${config.home.username}_${osConfig.networking.hostName}_rsa";
          rounds = 100;
          openSSHFormat = true;
        }
        {
          type = "ed25519";
          path = "${config.home.username}_${osConfig.networking.hostName}_ed25519";
          rounds = 100;
          comment = "key comment";
        }
      ];
      description = ''
        NixOS can automatically generate SSH host keys.  This option
        specifies the path, type and size of each key.  See
        {manpage}`ssh-keygen(1)` for supported types
        and sizes. Paths are relative to home directory
      '';
    };
  };

  config = lib.mkMerge [
    (
      lib.mkIf ((builtins.length config.programs.openssh.hostKeys) != 0) {
        services.ssh-agent.enable = true;
        programs.ssh = {
          enable = true;
          compression = true;
          addKeysToAgent = "confirm";
          extraConfig = lib.strings.concatLines (
            builtins.map (hostKey: "IdentityFile ~/.ssh/${hostKey.path}") config.programs.openssh.hostKeys
          );
        };

        systemd.user.services = builtins.listToAttrs (
          builtins.map (hostKey:
            lib.attrsets.nameValuePair "ssh-gen-keys-${hostKey.path}" {
              Install = {
                WantedBy = ["default.target"];
              };
              Service = let
                path = "${config.home.homeDirectory}/.ssh/${hostKey.path}";
              in {
                Restart = "always";
                Type = "simple";
                ExecStart = "${
                  pkgs.writeShellScript "ssh-gen-keys" ''
                    if ! [ -s "${path}" ]; then
                        if ! [ -h "${path}" ]; then
                            rm -f "${path}"
                        fi
                        mkdir -p "$(dirname '${path}')"
                        chmod 0755 "$(dirname '${path}')"
                        ${pkgs.openssh}/bin/ssh-keygen \
                          -t "${hostKey.type}" \
                          ${lib.optionalString (hostKey ? bits) "-b ${toString hostKey.bits}"} \
                          ${lib.optionalString (hostKey ? rounds) "-a ${toString hostKey.rounds}"} \
                          ${lib.optionalString (hostKey ? comment) "-C '${hostKey.comment}'"} \
                          ${lib.optionalString (hostKey ? openSSHFormat && hostKey.openSSHFormat) "-o"} \
                          -f "${path}" \
                          -N ""
                        chown ${config.home.username} ${path}*
                        chgrp ${config.home.username} ${path}*
                    fi
                  ''
                }";
              };
            })
          config.programs.openssh.hostKeys
        );
      }
    )
    (lib.mkIf osConfig.host.impermanence.enable {
      home.persistence."/persist${config.home.homeDirectory}" = {
        files = lib.lists.flatten (
          builtins.map (hostKey: [".ssh/${hostKey.path}" ".ssh/${hostKey.path}.pub"]) config.programs.openssh.hostKeys
        );
      };
    })
  ];
}
