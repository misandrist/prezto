#
# Configures Emacs dependency management.
#
# Authors: Sebastian Wiesner <lunaryorn@gmail.com>
#

# Emacs OS X installation styles:
#
# zstyle ':prezto:module:emacs' system MacPorts
#     Emacs is under /Applications/MacPorts
#
# zstyle ':prezto:module:emacs' system AquaMacs
#     Emacs is under /Applications

setup_os_x_emacs() {
    if ! zstyle -t ":prezto:module:emacs" system MacPorts AquaMacs; then
        return
    fi

    readonly apps_root=/Applications
    readonly macports_root=${apps_root}/MacPorts
    readonly emacs=/Contents/MacOS/Emacs
    readonly emacs_bin=${emacs}/bin

    if zstyle -t ":prezto:module:emacs" system MacPorts; then
        readonly emacs_root=${macports_root}/Emacs.app
    else
        readonly emacs_root=${apps_root}/Emacs.app
    fi

    export EMACS=${emacs_root}/Contents/MacOS/Emacs

    path=(
        ${emacs_root}/Contents/MacOS/bin
        $path
    )
}

setup_os_x_emacs

export EDITOR=emacsclient

# Return if requirements are not found.
if [[ -d "$HOME/.cask" ]]; then
    # Prepend Cask bin directory.
    path=($HOME/.cask/bin $path)

    # Load Carton completion
    source "$HOME/.cask/etc/cask_completion.zsh" 2> /dev/null

    #
    # Aliases
    #
    alias cai='cask install'
    alias cau='cask update'
    alias caI='cask init'
    alias cae='cask exec'
fi
