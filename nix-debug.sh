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

nix build --log-lines 0 --print-build-logs ".#$target"
