#
# Defines tmux aliases and provides for auto launching it at start-up.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#   Colin Hebert <hebert.colin@gmail.com>
#   Georges Discry <georges@discry.be>
#   Xavier Cambar <xcambar@gmail.com>
#

# Return if requirements are not found.
if (( ! $+commands[tmux] )); then
  return 1
fi


# Version -> Feature map
declare -A -r version_features=(
    "tmux_2.1" "tmpdir"
)

declare -r tmux_version="$(tmux -V | sed 's/[ .]/_/g')"
declare -r -a tmux_features=("${(ws#:#)vsns[${tmux_version}]}")

require_feature() {
    local -r feature=$1; shift

    return [ -n "${tmux_features[(r)${feature}]}"]
}

# Check for the TMUX_TMPDIR setting
zstyle -s ':prezto:module:tmux:socketdir' tmux_tmpdir TMUX_TMPDIR

ensure_tmux_tmpdir() {
    local -r tmpdir="$1"

    if ! mkdir -p "$tmpdir"; then
        echo "WARNING: could not create tmux_tmpdir: ${tmpdir}"
        return 1
    fi
}

# Support for version of tmux without TMUX_TMPDIR support
_tmux_no_tmpdir() {
    tmux -S $TMUX_TMPDIR "$@"
}

if [ -n "$TMUX_TMPDIR" -a ! -d "$TMUX_TMPDIR" ]; then
    ensure_tmux_tmpdir "$TMUX_TMPDIR" || unset TMUX_TMPDIR

    if ! require_feature tmpdir; then
        alias tmux=_tmux_no_tmpdir
    else
        export TMUX_TMPDIR
    fi
fi

#
# Auto Start
#

if ([[ "$TERM_PROGRAM" = 'iTerm.app' ]] && \
  zstyle -t ':prezto:module:tmux:iterm' integrate \
); then
  _tmux_iterm_integration='-CC'
fi

if [[ -z "$TMUX" && -z "$EMACS" && -z "$VIM" ]] && ( \
  ( [[ -n "$SSH_TTY" ]] && zstyle -t ':prezto:module:tmux:auto-start' remote ) ||
  ( [[ -z "$SSH_TTY" ]] && zstyle -t ':prezto:module:tmux:auto-start' local ) \
); then
  tmux start-server

  # Create a 'prezto' session if no session has been defined in tmux.conf.
  if ! tmux has-session 2> /dev/null; then
    tmux_session='prezto'
    tmux \
      new-session -d -s "$tmux_session" \; \
      set-option -t "$tmux_session" destroy-unattached off &> /dev/null
  fi

  # Attach to the 'prezto' session or to the last session used.
  exec tmux $_tmux_iterm_integration attach-session
fi

#
# Aliases
#

alias tmuxa="tmux $_tmux_iterm_integration new-session -A"
alias tmuxl='tmux list-sessions'
