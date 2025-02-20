{
  buildNpmPackage,
  lib,
  ...
}:
let
  version = "0.0.1";
in
buildNpmPackage {
  pname = "simplefolio";
  inherit version;

  src = ../.;
  npmDepsHash = "sha256-g4NqPePVsEbf50jc2WpBrsCdHhH9x1DVFDut8kK1P4I=";

  buildPhase = ''
    runHook preBuild
    npm run build
    cp -r ./dist $out
    runHook postBuild
  '';

  doDist = false;

  meta = {
    description = "A minimal portfolio template for Developers (fork)";
    homepage = "https://github.com/arminfro/simplefolio";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
