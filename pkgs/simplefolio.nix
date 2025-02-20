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
  npmDepsHash = "sha256-Hj2sOZwapgkzqt2+5oOfeE6M64XSXAa429bfVXaHfiE=";

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
