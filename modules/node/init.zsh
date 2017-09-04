#
# Loads the Node Version Manager and enables npm completion.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#   Zeh Rizzatti <zehrizzatti@gmail.com>
#

# Load manually installed NVM into the shell session.
if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
  source "$HOME/.nvm/nvm.sh"

# Load package manager installed NVM into the shell session.
elif (( $+commands[brew] )) && [[ -d "$(brew --prefix nvm 2>/dev/null)" ]]; then
  source $(brew --prefix nvm)/nvm.sh

# Return if requirements are not found.
elif (( ! $+commands[node] )); then
  return 1
fi

# Load NPM completion.
if (( $+commands[npm] )); then
  cache_file="${0:h}/cache.zsh"

  if [[ "$commands[npm]" -nt "$cache_file" || ! -s "$cache_file" ]]; then
    # npm is slow; cache its output.
    npm completion >! "$cache_file" 2> /dev/null
  fi

  source "$cache_file"

  unset cache_file
fi

setup_npm_global_root() {
    local npm_global_root;

    zstyle -g npm_global_root ':prezto:module:node:npm' global_root

    if [ -n "$npm_global_root" ]; then
        export NPM_PACKAGES="${npm_global_root}"
        path=(
            "${npm_global_root}/bin"
            "${path[@]}"
        )
        manpath=("${npm_global_root}/man" "${manpath[@]}")
    fi
}

init_node_modules_hook () {
    node_modules_paths=(node_modules/.bin)

    _local_node_modules_path () {
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
            for p in ${node_modules_paths[@]}; do
                if [ -d "$d/$p" ]; then
                    path=($d/$p $path)
                    break
                fi
            done

            d=$(dirname $d)
        done
    }

    autoload -Uz add-zsh-hook
    add-zsh-hook preexec _local_node_modules_path
}

setup_npm_global_root
init_node_modules_hook
