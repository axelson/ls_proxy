#!/usr/bin/env bash
set -e

#RELEASE_DIR=~/dev/forks/vscode-elixir-ls/elixir-ls-release
RELEASE_DIR=/tmp/ls_proxy_release

echo "Building ls_proxy"
pushd /home/jason/dev/ls_proxy/app
env MIX_ENV=prod LS_HTTP_PROXY_TO='http://localhost:4000/api/messages' mix escript.build
popd
echo -e "\nDone!"

cp ~/dev/ls_proxy/app/app $RELEASE_DIR/language_server.sh
