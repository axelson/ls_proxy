#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd $SCRIPT_DIR

if [ -x ~/.vscode ]; then
    EXT_DIR=~/.vscode
fi

if [ -x ~/.vscode-oss ]; then
    EXT_DIR=~/.vscode-oss
fi

echo "EXT_DIR: $EXT_DIR"
ELIXIR_LS_DIR=$(ls $EXT_DIR/extensions/ | grep .elixir-ls-)
echo "ELIXIR_LS_DIR $ELIXIR_LS_DIR"
START_SCRIPT_PATH=$EXT_DIR/extensions/$ELIXIR_LS_DIR/elixir-ls-release/language_server.sh
echo "START_SCRIPT_PATH $START_SCRIPT_PATH"
cp app $START_SCRIPT_PATH
