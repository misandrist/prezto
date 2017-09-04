#
# Enables local Haskell package installation.
#
# Authors:
#   Sebastian Wiesner <lunaryorn@googlemail.com>
#   Evan Cofsky <evan@theunixman.com>
#

_hvr () {
    # Should we use hvr's ghc?
    zstyle -b ':prezto:module:haskell' hvr ghc_hvr

    if [ "$ghc_hvr" = "yes" ]; then
        path=(/opt/ghc/bin $path)
    fi
}

_global_sandbox () {
    # Do we have a global sandbox?
    zstyle -g _global_sandbox ':prezto:module:haskell' global-sandbox
    if [[ "${_global_sandbox}" ]]; then
        path=("${_global_sandbox}"/bin $path)
    fi
}

_hoogle () {
    local ddopt;
    zstyle -g hoogle_datadir ':prezto:module:haskell:hoogle' datadir

    if [ -n "$hoogle_datadir" ]; then
        ddopt="--databases=$hoogle_datadir"
    fi

    alias hoogle="$(which hoogle) search $ddopt $@"
}

# Prepend Cabal per user directories to PATH.
path=(
    ./.cabal-sandbox/bin(/N)
    ./cabal-sandbox/bin(/N)
    $HOME/Library/Haskell/bin(/N)
    $HOME/.cabal/bin(/N)
    $cabal_path(/N)
    $path
)

_init_sandbox_hook () {
    # Paths that a cabal sandbox might be under.
    cabal_sandbox_paths=(.cabal-sandbox cabal-sandbox)

    _local_cabal_sandbox_path () {
        local -a pths

        local oldd i p
        oldd=$OLDPWD

        for ((i=1; i <= ${#path}; i+=1)); do
            p=${path[$i]}

            if [[ $p =~ $oldd ]]; then
                path[i]=()
            fi
        done

        local d
        d=$PWD
        while [ $d != "/" ]; do
            for p in ${cabal_sandbox_paths[@]}; do
                if [ -d "$d/$p" ]; then
                    path=($d/$p/bin $path)
                    break
                fi
            done

            d=$(dirname $d)
        done

        zstyle -g _global_sandbox ':prezto:module:haskell' global-sandbox
        if [[ "${_global_sandbox}" ]]; then
            path=("${_global_sandbox}"/bin(/N) $path)
        fi
    }

    autoload -Uz add-zsh-hook
    add-zsh-hook preexec _local_cabal_sandbox_path
}

_hvr
_global_sandbox
_hoogle
_init_sandbox_hook

unset _hvr _global_sandbox _hoogle _init_sandbox_hook
