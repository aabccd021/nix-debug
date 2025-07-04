target=${1:-}
shift || true

flags="$*"

trap 'cd $(pwd)' EXIT
root=$(git rev-parse --show-toplevel)
cd "$root" || exit
git add -A
trap 'git reset >/dev/null' EXIT

system=$(nix eval --impure --raw --expr 'builtins.currentSystem')

if [ -z "$target" ]; then
  packages=$(nix flake show --json | jq --raw-output ".packages.\"$system\" | keys[]")
  if [ -z "$packages" ]; then
    echo "No packages found for system $system"
    exit 1
  fi
  target=$(echo "$packages" | sed "s|^|.#|" | fzf --prompt="Select a package: ")
fi

outpath=$(nix derivation show "$target" | jq -r 'values[].env.out')
if [ -e "$outpath" ]; then
  # shellcheck disable=SC2086
  PAGER='' nix log $flags "$target"
  exit 1
else
  # shellcheck disable=SC2086
  nix build --print-build-logs $flags "$target"
fi
