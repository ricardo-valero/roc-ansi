#!/bin/bash

if [[ "$TERM" == "xterm"* || "$TERM" == "screen"* || "$TERM" == "tmux"* ]]; then
    echo -e "\e[32mYour terminal supports colors!\e[0m"
else
    echo "Your terminal does not support colors."
fi
