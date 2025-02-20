{
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      flake.nixosModules.default = import ./service.nix {
        inherit self;
      };

      perSystem =
        { pkgs, system, ... }:
        {
          packages = import ./pkgs { inherit pkgs; };
          devShells.default = pkgs.mkShell {
            buildInputs = with pkgs; [
              ungoogled-chromium
              nodePackages.nodejs
              nodePackages.pnpm
              nodePackages.typescript
              nodePackages.typescript-language-server
            ];
            shellHook =
              # bash
              ''
                cleanup() {
                  echo "Cleaning up..."
                  # Kill all child processes of the current shell
                  pkill -P $$
                }

                start-dev() {
                  if [ ! -d "node_modules" ]; then
                    ${pkgs.pnpm}/bin/pnpm install
                  fi

                  ${pkgs.pnpm}/bin/pnpm dev &
                  ${pkgs.ungoogled-chromium}/bin/chromium-browser \
                    --user-data-dir=./.chromium-browser-data \
                    --enable-features=UseOzonePlatform \
                    --ozone-platform=wayland > /dev/null 2>&1 &

                  # Trap SIGINT signal (Ctrl-C) to call cleanup function
                  trap cleanup INT
                  wait
                }

                export PATH=$PATH:./node_modules/.bin

                echo "To start the development server, run 'start-dev'"
              '';
          };
        };
    };
}
