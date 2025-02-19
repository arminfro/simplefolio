{ self }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.simplefolio;
in
{
  options.services.simplefolio = {
    enable = lib.options.mkEnableOption "enable simplefolio";
    virtualHost = lib.mkOption {
      default = "127.0.0.1";
      type = lib.types.str;
      description = "The virtualHost to listen on";
    };

  };
  config = lib.mkIf cfg.enable {
    services.nginx = {
      enable = true;
      virtualHosts."${cfg.virtualHost}" = {
        root = self.outputs.packages.${pkgs.system}.default;
      };
    };
  };
}
