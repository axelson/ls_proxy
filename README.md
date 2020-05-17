# LsProxy

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
Editor <-> LsProxy <-> LanguageServer
```

LsProxy reads input from the Editor (stdin), collects metrics on it, and then sends it to the LanguageServer, and sends all responses back to the Editor.

It also exposes a website with metrics of what was sent to aid in debugging and understanding a LanguageServer.

Steps:
1) Read from stdin
2) Read from stdin until killed (or receive eof?)
3) Forward on to the LanguageServer
4) Return output from the LanguageServer to the Editor 

LsProxy architecture:
```
            LsProxy.Collector
                    ^
                    |
                    v
EditorPort <-> LsProxy.Tee <-> LanguageServerPort
```

`EditorPort` to `LsProxy.Tee` is controlled purely by our `stdin` and `stdout`
`LsProxy.Tee` communicates with `LanguageServerPort` via `erlexec`

And the `LsProxy.Collector` collects the metrics info to be displayed via HTTP or other interfaces

Since EditorPort is the entrypoint into the system it will be the group leader for all of the processes because it has to write to stdout (not implemented yet).

# Running

```
cd ~/dev/ls_proxy
# maybe env MIX_ENV=prod LS_HTTP_PROXY_TO='http://localhost:4000/api/messages' mix escript.build; cp app /tmp/ls_proxy_release/language_server.sh
# maybe env MIX_ENV=prod mix escript.build; cp app /tmp/ls_proxy_release/language_server.sh

cd ~/dev/forks/vscode-elixir-ls/
git checkout ls-proxy
vsce package
code --install-extension ./elixir-ls-0.3.1.vsix  --force
code

# In a browser navigate to:
# http://localhost:5000
```

# Configuration

Env var `LS_PROXY_TO`: Where to find the LanguageServer to proxy to (defaults to `"elixir-ls/release/language_server.sh"`)

Typically used only for development:

Env var `LS_HTTP_PROXY_TO`: Where to send copies of the HTTP messages to, useful to quickly iterate on the web frontend
Env var `LS_PROXY_RUN_LANGUAGE_SERVER`: Controls if we start up `LsProxy.ProxyPort` (defaults to `true`)

# TODO

- [x] parse basic messages
- [x] work transparently but with some logging
- [x] move to poncho style project and create a phoenix web server
- [x] Add Phoenix LiveView
- [x] implement two modes, direct where we receive input from stdin and http where we receive input over http
- [x] Compile ls_proxy to proxy requests to a standalone instance
- [x] Get clustering to work for easier debugging
- [x] Issue: large messages are being broken up, causing parsing issues
- [x] Display just the method for each message
- [x] Add a button to show the whole message
- [x] Get app.css and app.js to be compiled before StaticAssetController so we can compile them into StaticAssetController (or another module)
- [x] Show request/response timings
- [x] Don't require erlang distribution to already be started up
- [x] Don't fail if port 5000 is already taken
  - Maybe we can no set `server: true` initially but start up the server after the fact, that wasy we can register a handler to see if it failed (or in the Endpoint.init callback we can check what ports we've already tried)
- [x] Add ability to log to lsp output
- [x] Print http port running on to lsp output
- [x] Update to latest Phoenix LiveView
- [x] Make requests/messages toggleable as screens
- [ ] Update filtered requests whenever messages changes
- [ ] Organize messages page for usability
- [ ] Render messages on homepage instead of messages pages

Later:
- [ ] Show cancelled request/responses
- [ ] Show client capabilities
- [ ] Make the request/response section scannable and usable
- [ ] Show server capabilities
- [ ] Show current diagnostics (warnings/errors)
  - [ ] And provide a way to drill down into what the lsp messages were and the messages around the same time
- [ ] `LsProxy.ErrorCodesParser` should show server error code when errror is between `serverErrorStart` and `serverErrorEnd` (e.g. `"ServerError -32001"`)
- [ ] Limit number of stored messages
  - Ideally would drop the request along with the response
- [ ] Use `Node.start/3`: https://hexdocs.pm/elixir/Node.html#start/3
- [ ] Generate a random node name, and display the node name on the home page
- [ ] Track down byte_length issue in messages_view.ex

Later:
- [ ] Issue: not reliably sending messages via json and via "plain-text" (is this worth fixing?)

Maybe:
- [ ] Use boundary instead of multiple apps
- [ ] Switch to using releases instead of an escript

Long-term:
- [ ] collect client-server communication for bug filing on clients and servers
- [ ] A way to view collected logs after the fact
  - lsp-mode: `(setq lsp-print-io t)`
  - vscode: C-S-p -> User Settings -> type "trace" mark css language server to use verbose and then from the output view you will find the vscode trace log
- [ ] if the specified port is taken, try the next one
  - [ ] and register with that other server so we can do discovery
- [ ] Support language-server-protocol-inspector format (is there docs for this?)

Once published, the docs can be found at
[https://hexdocs.pm/ls_proxy](https://hexdocs.pm/ls_proxy).

Related:
* https://github.com/Microsoft/language-server-protocol-inspector

Future Features:
* Render a web page showing the features that the server supports
* Support TCP sockets? Is that even part of LSP?
