#!/bin/bash

set -xe

echo "Building ls_proxy"
pushd /home/jason/dev/ls_proxy/app
env MIX_ENV=prod LS_HTTP_PROXY_TO='http://localhost:4000/api/messages' mix escript.build
popd
echo -e "\nDone!"

# Don't need this because we build in prepublish.sh
#echo "Building elixir-ls"
#pushd /home/jason/config/repos/elixir-ls
##pushd /home/jason/dev/forks/elixir-ls
#mix elixir_ls.release
#popd
#echo -e "\nDone!"

echo "Building vsce"
vsce package
echo -e "\nDone!"
