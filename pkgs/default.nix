{ pkgs }:
{
  default = pkgs.callPackage ./simplefolio.nix { };
  mailform = pkgs.callPackage ./mailform.nix { };
}
