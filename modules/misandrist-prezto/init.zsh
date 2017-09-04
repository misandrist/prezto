#
# Misandrist customizations
#
# Authors:
#   Evan Cofsky <evan@theunixman.com>
#

_dircolors () {
    zstyle -b ':prezto:module:misandrist:dircolors' misandrist internal
    zstyle -b ':prezto:module:misandrist:dircolors' misandrist install

    local -r ma_dircolors="$HOME/.zprezto/modules/misandrist/dircolors"
    local -r home_dircolors="$HOME/.dircolors"
    if [[ "$internal" = "yes" ]]; then
        readonly dcrcpath="${ma_dircolors}"
    else
        readonly dcrdpath="${home_dircolors}"
        if [[ "$install" = "yes" && ! -r "${dcrdpath}" ]]; then
            (cd $HOME && ln -s "${ma_dircolors} .dircolors")
        else
            echo "WARN: No file ${dcrdpath} but neither internal nor install specified. " >&2
        fi
    fi

    [ -f "${dcrdpath}" ] && eval $(dircolors "${dcrdpath}")
}

_dircolors

unset _dircolors
