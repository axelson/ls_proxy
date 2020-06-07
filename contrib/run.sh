#!/bin/bash

# elixir_ls
pushd ~/dev/forks/elixir-ls
#mix elixir_ls.release -o ~/.vscode-oss/extensions/jakebecker.elixir-ls-0.4.0/elixir-ls-release/
mix elixir_ls.release

# Shell proxy
cp /home/jason/dev/ls_proxy/contrib/shell_proxy.sh ~/.vscode-oss/extensions/jakebecker.elixir-ls-0.4.0/elixir-ls-release/language_server.sh
