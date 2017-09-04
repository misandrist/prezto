# Set the default paths to gpg-agent files.
_gpg_home="${GNUPGHOME:-$HOME/.gnupg}"
_gpg_agent_conf="${_gpg_home}/gpg-agent.conf"
_gpg_agent_socket="${_gpg_home/S.gpg-agent}"

gpgv1_init() {
    # Handle start-up for gpg2.

    #
    # Provides for an easier use of GPG1 by setting up gpg-agent.
    #
    # Authors:
    #   Sorin Ionescu <sorin.ionescu@gmail.com>
    #

    _gpg_agent_env="${TMPDIR:-/tmp}/gpg-agent.env"

    # Start gpg-agent if not started.
    if [[ -z "$GPG_AGENT_INFO" && ! -S "${_gpg_agent_socket}" ]]; then
        # Export environment variables.
        source "$_gpg_agent_env" 2> /dev/null

        # Start gpg-agent if not started.
        if ! ps -U "$LOGNAME" -o pid,ucomm | grep -q -- "${${${(s.:.)GPG_AGENT_INFO}[2]}:--1} gpg-agent"; then
            eval "$(gpg-agent --daemon | tee "$_gpg_agent_env")"
        fi
    fi

    # Inform gpg-agent of the current TTY for user prompts.
    export GPG_TTY="$(tty)"

    # Integrate with the SSH module.
    if grep 'enable-ssh-support' "$_gpg_agent_conf" &> /dev/null; then
        # Load required functions.
        autoload -Uz add-zsh-hook

        # Override the ssh-agent environment file default path.
        _ssh_agent_env="$_gpg_agent_env"

        # Load the SSH module for additional processing.
        pmodload 'ssh'

        # Updates the GPG-Agent TTY before every command since SSH does not set it.
        function _gpg-agent-update-tty {
            gpg-connect-agent UPDATESTARTUPTTY /bye &> /dev/null
        }
        add-zsh-hook preexec _gpg-agent-update-tty
    fi
}

gpgv2_init() {
    # Handle start-up for gpg2.

    #
    # Provides for an easier use of GPG2 by setting up gpg-agent.
    #
    # Authors:
    #   Sorin Ionescu <sorin.ionescu@gmail.com>
    #   Evan Cofsky <evan@theunixman.com>
    #

    _gpg_agent_ssh_socket="${_gpg_home}/S.gpg-agent.ssh"

    # Ensure the agent is running
    gpg-connect-agent /bye > /dev/null < /dev/null

    # Integrate with the SSH module.
    if grep 'enable-ssh-support' "$_gpg_agent_conf" &> /dev/null; then

        # Load required functions.
        autoload -Uz add-zsh-hook

        # Override the ssh-agent environment file default path.
        _ssh_agent_env=/dev/null
        _ssh_agent_sock="${_gpg_agent_ssh_socket}"
        export SSH_AUTH_SOCK="${_ssh_agent_sock}"

        # Load the SSH module for additional processing.
        pmodload 'ssh'

        # Updates the GPG-Agent TTY before every command since SSH does not set it.
        function _gpg-agent-update-tty {
            gpg-connect-agent UPDATESTARTUPTTY /bye >/dev/null
        }
        add-zsh-hook preexec _gpg-agent-update-tty
    fi
}

# Return if requirements are not found.
if (( ! $+commands[gpg-agent] )); then
  return 1
fi

if (( $+commands[gpg2] )); then
    gpgv2_init
else
    gpgv1_init
fi

# Clean up.
unset _gpg_home _gpg_agent_conf _gpg_agent_socket

# Disable GUI prompts inside SSH.
if [[ -n "$SSH_CONNECTION" ]]; then
    export PINENTRY_USER_DATA='USE_CURSES=1'
fi
