# set -eu

trap 'cd $(pwd)' EXIT
root=$(git rev-parse --show-toplevel)
cd "$root" || exit
git add -A
trap 'git reset >/dev/null' EXIT

target=${1:-}

if [ -z "$target" ]; then
  target=$(
    nix flake show --json |
      jq --raw-output '.packages."x86_64-linux" | keys[]' |
      fzf
  )
fi

outpath=$(nix derivation show ".#$target" | jq -r 'values[].env.out')
if [ -e "$outpath" ]; then
  echo "Showing build log of .#$target"
  nix log ".#$target"
else
  nix build --print-build-logs ".#$target"
fi
