{
  description = "Dot Hop - Godot game dev shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f (import nixpkgs { inherit system; }));
    in
    {
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [
            pkgs.godot_4_5 # Godot pinned to 4.5.x to match project.godot
            pkgs.babashka # `bb` tasks (see bb.edn)
            pkgs.watchexec # native file watcher for `bb watch` (see bb/tasks.clj)
          ];
        };
      });

      # `nix run` launches the game directly.
      apps = forAllSystems (pkgs: {
        default = {
          type = "app";
          program = "${pkgs.writeShellScript "dothop-run" ''
            exec ${pkgs.godot_4_5}/bin/godot --path ${toString ./.} "$@"
          ''}";
        };
      });
    };
}
