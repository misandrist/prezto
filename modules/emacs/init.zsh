#
# Configures Emacs dependency management.
#
# Authors: Sebastian Wiesner <lunaryorn@gmail.com>
#

# Styles:
#
# zstyle ':prezto:module:emacs' system MacPorts
# zstyle ':prezto:module:emacs' system AquaMacs
# zstyle ':prezto:module:emacs' system Unix

OS_X_APPS_ROOT=/Applications
OS_X_EMACS=/Contents/MacOS/Emacs
OS_X_EMACS_BIN=/Contents/MacOS/bin

if zstyle -t ":prezto:module:emacs" system MacPorts; then
    OS_X_APPS_ROOT=${OS_X_APPS_ROOT}/MacPorts
fi

if zstyle -t ":prezto:module:emacs" system MacPorts AquaMacs; then
    EMACS_ROOT=${OS_X_APPS_ROOT}/Emacs.app
    EMACS=${EMACS_ROOT}/Contents/MacOS/Emacs
    EMACS_BIN=${EMACS_ROOT}/Contents/MacOS/bin
    path=(
        ${EMACS_BIN}
        $path
    )
    export EMACS=${EMACS}
fi

# Return if requirements are not found.
if [[ ! -d "$HOME/.cask" ]]; then
  return 1
fi

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
