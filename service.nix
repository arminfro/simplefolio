{ self }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.simplefolio;
  outputPackages = self.outputs.packages.${pkgs.system};

  user = "mailform";
  group = "mailform";
  dataDir = "/var/lib/mailform";
  defaultTargetsDir = "${dataDir}/targets";
  mailFormPortStr = builtins.toString cfg.mailform.port;
  appDomain = "${cfg.subDomain}.${cfg.domain}";
in
{
  options.services.simplefolio = {
    enable = lib.options.mkEnableOption "enable simplefolio";
    domain = lib.mkOption {
      default = "localhost";
      type = lib.types.str;
      description = "The domain to set nginx virtualHost root";
    };
    subDomain = lib.mkOption {
      default = "about";
      type = lib.types.str;
      description = "The subDomain to set nginx virtualHost root";
    };
    mailform = lib.mkOption {
      type = lib.types.submodule {
        options = {
          targetsDir = lib.mkOption {
            default = defaultTargetsDir;
            type = lib.types.nullOr lib.types.str;
            description = "Path to Targets (see https://github.com/Feuerhamster/mailform#targets)";
          };
          port = lib.mkOption {
            type = lib.types.port;
            default = 3011;
            description = ''
              Port for the server to listen on.
            '';
          };
          subDomain = lib.mkOption {
            default = "mailform";
            type = lib.types.str;
            description = "The subDomain to set nginx virtualHost root";
          };
        };
      };
    };

  };
  config = lib.mkIf cfg.enable {
    services.nginx = {
      enable = true;
      virtualHosts = {
        "${appDomain}" = {
          root = outputPackages.default;
          locations."/".extraConfig = ''
            access_log /var/log/nginx/simplefolio.log;
          '';
        };
        "${cfg.mailform.subDomain}.${cfg.domain}" = {
          extraConfig = ''
            access_log /var/log/nginx/mailform.log;
          '';
          locations."/" = {
            proxyPass = "http://127.0.0.1:${mailFormPortStr}";
          };
        };
      };
    };

    systemd.services.mailform-for-simplefolio = {
      description = "Mailform for Simplefolio";

      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = user;
        Group = group;
        WorkingDirectory = dataDir;
        Environment =
          [
            "PORT=${mailFormPortStr}"
            "PROXY='true'"
          ]
          ++ lib.optional (
            builtins.hasAttr "targetsDir" cfg && cfg.targetsDir != defaultTargetsDir
          ) "TARGETS_DIR=${cfg.targetsDir}";
        ExecStart = "${outputPackages.mailform}/bin/mailform";
        Restart = "on-failure";
      };
    };

    users.users = {
      "${user}" = {
        isSystemUser = true;
        group = group;
        home = dataDir;
      };
    };

    users.groups = {
      "${group}" = { };
    };

  };
}
