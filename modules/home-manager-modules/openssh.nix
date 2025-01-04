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
      default = [
        {
          type = "ed25519";
          path = ".ssh/${config.home.username}_${osConfig.networking.hostName}_ed25519";
        }
      ];
      example = [
        {
          type = "rsa";
          bits = 4096;
          path = ".ssh/${config.home.username}_${osConfig.networking.hostName}_rsa";
          rounds = 100;
          openSSHFormat = true;
        }
        {
          type = "ed25519";
          path = ".ssh/${config.home.username}_${osConfig.networking.hostName}_ed25519";
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
    {
      systemd.user.services."${config.home.username}-ssh-keygen" = {
        Unit = {
          description = "Generate SSH keys for user";
        };
        Install = {
          wantedBy = ["sshd.target" "multi-user.target" "default.target"];
        };
        Service = {
          ExecStart = "${
            pkgs.writeShellScript "ssh-keygen"
            ''
              # Make sure we don't write to stdout, since in case of
              # socket activation, it goes to the remote side (#19589).
              exec >&2

              ${lib.flip lib.concatMapStrings config.programs.openssh.hostKeys (k: let
                path = "${config.home.homeDirectory}/${k.path}";
              in ''
                if ! [ -s "${path}" ]; then
                    if ! [ -h "${path}" ]; then
                        rm -f "${path}"
                    fi
                    mkdir -p "$(dirname '${path}')"
                    chmod 0755 "$(dirname '${path}')"
                    ssh-keygen \
                      -t "${k.type}" \
                      ${lib.optionalString (k ? bits) "-b ${toString k.bits}"} \
                      ${lib.optionalString (k ? rounds) "-a ${toString k.rounds}"} \
                      ${lib.optionalString (k ? comment) "-C '${k.comment}'"} \
                      ${lib.optionalString (k ? openSSHFormat && k.openSSHFormat) "-o"} \
                      -f "${path}" \
                      -N ""
                fi
              '')}
            ''
          }";
          KillMode = "process";
          Restart = "always";
          Type = "simple";
        };
      };
    }
    (lib.mkIf osConfig.host.impermanence.enable {
      home.persistence."/persist${config.home.homeDirectory}" = {
        files = lib.lists.flatten (
          builtins.map (hostKey: [hostKey.path "${hostKey.path}.pub"]) config.programs.openssh.hostKeys
        );
      };
    })
  ];
}
