#
# Enables local Haskell package installation.
#
# Authors:
#   Sebastian Wiesner <lunaryorn@googlemail.com>
#

# Return if requirements are not found.
if (( ! $+commands[ghc] )); then
  return 1
fi

# Prepend Cabal per user directories to PATH.
path=(
    ./.cabal-sandbox/bin(/N)
    $HOME/Library/Haskell/bin(/N)
    $HOME/.cabal/bin(/N)
    $path
)

sandbox_path () {
    oldd=$OLDPWD/.cabal-sandbox/bin
    for p in $path; do
        if [[ $p =~ $oldd ]]; then
            i=$path[(i)$p]
            path[i]=()
        fi
    done

    d=$PWD
    while [[ $d != "/" ]]; do
        p=$d/.cabal-sandbox/bin
        if [[ -d $p ]]; then
            path=(
                $p
                $path
            )
            break;
        fi
        d=$(dirname $d)
    done
}

chpwd_functions=(
    sandbox_path
    $chpwd_functions
    )
