{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs = { self, nixpkgs, systems }: let
    forEachSystem = nixpkgs.lib.genAttrs (import systems);
  in
  {
    packages = forEachSystem (system: 
      let
        pkgs = nixpkgs.legacyPackages.${system};
        nodejs = pkgs.nodejs_18;
        inherit (pkgs.lib) extends makeExtensible;
        node-packages = final: import ./generated/default.nix {
          inherit pkgs nodejs system;
        };
        nodePackages = makeExtensible (extends
          (import ./overrides.nix { inherit pkgs nodejs; })
          node-packages);
      in
      {
        inherit (nodePackages) wrangler;
      }
    );
  };
}
