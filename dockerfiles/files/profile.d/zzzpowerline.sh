#!/bin/bash

function _update_ps1() {
    PS1=$(powerline-go -colorize-hostname -cwd-max-depth 3 -modules host,cwd,git,exit -truncate-segment-width 10 $?)
}

if [[ $TERM != linux && ! $PROMPT_COMMAND =~ _update_ps1 ]]; then
    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi
