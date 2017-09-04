#!/bin/zsh

setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
    echo Installing $rcfile
    (cd $HOME && ln -s "$rcfile" ".${rcfile:t}") || break
done

git submodule update --init
