# set -eu

trap 'cd $(pwd)' EXIT
root=$(git rev-parse --show-toplevel)
cd "$root" || exit
git add -A
trap 'git reset >/dev/null' EXIT

system=$(nix eval --impure --raw --expr 'builtins.currentSystem')

target=${1:-}

if [ -z "$target" ]; then
  packages=$(nix flake show --json | jq --raw-output ".packages.\"$system\" | keys[]")
  if [ -z "$packages" ]; then
    echo "No packages found for system $system"
    exit 1
  fi
  target=$(echo "$packages" | fzf --prompt="Select a package: ")
fi

outpath=$(nix derivation show ".#$target" | jq -r 'values[].env.out')
if [ -e "$outpath" ]; then
  set -x
  PAGER='' nix log ".#$target"
  set +x
else
  set -x
  nix build --print-build-logs ".#$target"
  set +x
fi
