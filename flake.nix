{
  description = "NixOS VSCode server";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    {
      # Primary modern outputs
      nixosModules.default = import ./modules/vscode-server;
      homeModules.default = import ./modules/vscode-server/home.nix;
      
      # Backwards compatibility attributes - these will still produce deprecation warnings
      # from Nix itself, but will continue to work
      nixosModule = self.nixosModules.default;
      nixosModules.home = self.homeModules.default;
    }
    // (let
      inherit (flake-utils.lib) defaultSystems eachSystem;
    in
      eachSystem defaultSystems (system: let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs.lib) hasSuffix optionalAttrs;
        auto-fix-vscode-server = pkgs.callPackage ./pkgs/auto-fix-vscode-server.nix { };
      in
        # The package depends on `inotify-tools` which is only available on Linux.
        optionalAttrs (hasSuffix "-linux" system) {
          packages = {
            inherit auto-fix-vscode-server;
            default = auto-fix-vscode-server;
          };
          checks = {
            inherit auto-fix-vscode-server;
          };
        }));
}
