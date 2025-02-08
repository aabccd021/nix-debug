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

nix derivation show ".#$target"

outpath=$(nix derivation show ".#$target" | jq -r 'values[].env.out')

echo "Outpath: $outpath"

# if [ -e "$outpath" ]; then
#   echo "-e $outpath"
# fi
#
# if [ -d "$outpath" ]; then
#   echo "-d $outpath"
# fi
#
# if [ -f "$outpath" ]; then
#   echo "-f $outpath"
# fi
#
# if [ -L "$outpath" ]; then
#   echo "-L $outpath"
# fi
#
# echo "hmm"
#
# file "$outpath" || true
# ls "$outpath" || true
#
# nix build --log-lines 0 --print-build-logs ".#$target"
#
echo "done"
# if ; then
#   echo "Not showing logs for $outpath"
#   nix build --log-lines 0 --print-build-logs ".#$target"
#   echo "Done"
# else
#   echo "Showing logs for $outpath"
#   nix log ".#$target"
#   echo "Done"
# fi
