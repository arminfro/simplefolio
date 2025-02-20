{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  pkgs,
  ...
}:
let
  version = "0.0.1";
in
buildNpmPackage {
  pname = "mailform";
  inherit version;

  src = fetchFromGitHub {
    owner = "Feuerhamster";
    repo = "mailform";
    rev = "727e9809985bc1b3abc4a8d15b7a7c47418acc21";
    hash = "sha256-rAWxpJYXtd0YroGb2Kn8VcZLZVFF10x07ENnEP/sXvE=";
  };

  npmDepsHash = "sha256-ldkuM3yXKCbfy8mGeF8w0NfsT58BLEC8f2zYT8gozwQ=";

  postInstall = ''
    mkdir $out/bin

    cat > $out/bin/mailform <<EOF
    #!${lib.getExe pkgs.bash}

    ${pkgs.nodejs}/bin/node $out/lib/node_modules/mailform/dist/main.js
    EOF

    chmod +x $out/bin/mailform
  '';

  meta = {
    description = "The lightweight self-hosted email service for contact forms and more! ";
    homepage = "https://github.com/Feuerhamster/mailform";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
