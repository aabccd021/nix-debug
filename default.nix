{ pkgs }:
{
  nix-debug = pkgs.writeShellApplication {
    name = "nix-debug";
    runtimeInputs = [
      pkgs.fzf
      pkgs.jq
    ];
    text = builtins.readFile ./nix-debug.sh;
  };
}
