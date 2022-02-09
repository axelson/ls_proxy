# LSP Proxy

![LSP Proxy Logo](LSPProxy_logo.png)

Proxy for [Language Server](https://microsoft.github.io/language-server-protocol/)'s.

It is kind of similar to:
https://github.com/Microsoft/language-server-protocol-inspector

But it is Live! You can see the messages coming in in real-time.

Architecture:
```
           Browser
              ^
              |
              v
Editor <-> LSP Proxy <-> LanguageServer
```

LSP Proxy reads input from the Editor (stdin), collects metrics on it, and then sends it to the LanguageServer, and sends all responses back to the Editor.

It also exposes a website with metrics of what was sent to aid in debugging and understanding a LanguageServer.

Steps:
1) Read from stdin
2) Read from stdin until killed (or receive eof?)
3) Forward on to the LanguageServer
4) Return output from the LanguageServer to the Editor 

LSP Proxy architecture:
```
            LSP Proxy.Collector
                    ^
                    |
                    v
EditorPort <-> LSP Proxy.Tee <-> LanguageServerPort
```

`EditorPort` to `LSP Proxy.Tee` is controlled purely by our `stdin` and `stdout`
`LSP Proxy.Tee` communicates with `LanguageServerPort` via `erlexec`

And the `LSP Proxy.Collector` collects the metrics info to be displayed via HTTP or other interfaces

Since EditorPort is the entrypoint into the system it will be the group leader for all of the processes because it has to write to stdout (not implemented yet).

# Running

```
git submodule update --init --recursive

cd ls_proxy # Note this is the ls_proxy folder in the repository, not the repository itself
env MIX_ENV=prod LS_PROXY_TO='elixir_ls' mix escript.build
cd ..

cd elixir-ls
rm -rf _build deps; mix deps.get
mix elixir_ls.release
cd ..

file ls_proxy/ls_proxy # Should print something like `a /usr/bin/env escript script executable (binary data)`

# This step will differ based on your editor

# For VSCode (double-check that the elixir-ls extension path is correct)
cp ls_proxy/ls_proxy ~/.vscode-oss/extensions/elixir-lsp.elixir-ls-0.7.0/elixir-ls-release/language_server.sh

# For Emacs this will depend on where you have installed ElixirLS
cp ls_proxy/ls_proxy /path/to/elixir-ls/release/language_server.sh

# Start your editor and open up an elixir file (to ensure that ls_proxy and ElixirLS are running)

# In a browser navigate to: http://localhost:5000
```

# Known Issues

There's a bug with the clustering logic, if you have multiple instances of LSP Proxy open then they might conflict.

# Configuration

Environment Variables:
- `LS_PROXY_TO`: Where to find the LanguageServer to proxy to
  - `"elixir_ls"` (default): a git submodule in this repository `"elixir-ls/release/language_server.sh"`
  - `"elixir_ls_dev"`: `~/dev/forks/elixir-ls/release/language_server.sh`
  - `"ls_proxy"`: `~/dev/ls_proxy/ls_proxy`

Typically used only for development:

Env var `LS_HTTP_PROXY_TO`: Where to send copies of the HTTP messages to, useful to quickly iterate on the web frontend
Env var `LS_PROXY_RUN_LANGUAGE_SERVER`: Controls if we start up `LSP Proxy.ProxyPort` (defaults to `true`)

Related:
* https://github.com/Microsoft/language-server-protocol-inspector

Future Features:
* Render a web page showing the features that the server supports
* Support TCP sockets? Is that even part of LSP?
