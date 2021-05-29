# TODO

- [ ] Test installing as an escript directly from mix
  - Could we bundle ElixirLS somehow?
- [ ] Turn into a single application?
- [ ] Pass through the messages unchanged
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
- [x] Render messages on homepage instead of messages pages
- [x] Organize messages page for usability
- [x] Allow filtering all tabs
- [x] Pressing reset doesn't clear requests and messages immediately
- [ ] Don't use MessagesView, instead use all live views/components
- [ ] a live reload doesn't set the query (problem with socket assigns/state? it is a controlled input)
- [ ] The ReqResp naming is terrible
- [ ] Change LsppWebWeb to LsppWeb (or LpWeb?)
- [ ] Update Contex
- [ ] Filter the requests bar chart also (add special handling when no requests match)
- [ ] Make it possible to hide the graph
- [ ] Update filtered requests whenever messages changes

Later:
- [ ] Show cancelled request/responses
- [ ] Show client capabilities
- [ ] Make the request/response section scannable and usable
- [ ] Show server capabilities
- [ ] Show current diagnostics (warnings/errors)
  - [ ] And provide a way to drill down into what the lsp messages were and the messages around the same time
- [ ] `LSP Proxy.ErrorCodesParser` should show server error code when errror is between `serverErrorStart` and `serverErrorEnd` (e.g. `"ServerError -32001"`)
- [ ] Limit number of stored messages
  - Ideally would drop the request along with the response
- [ ] Use `Node.start/3`: https://hexdocs.pm/elixir/Node.html#start/3
- [ ] Generate a random node name, and display the node name on the home page
- [ ] Track down byte_length issue in messages_view.ex
- [ ] Auto-complete in filter text input based on seen messages

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

# Notes

Language Server Protocol Notes
https://microsoft.github.io/language-server-protocol/specification

utf8 required
non-utf8 is an error

A message consists of a header and content
header and content separated by '\r\n'

The header consists of multiple fields
Each field has a name and value separated by `: `
Each header field is terminated with '\r\n'`

Header fields:
* Content-Length 	number 	The length of the content part in bytes. This header is required.
* Content-Type 	string 	The mime type of the content part. Defaults to application/vscode-jsonrpc; charset=utf-8

Content uses jsonrpc (is there a useful jsonrpc library in Elixir?)


Useful debugging commands
`mix escript.build`?
`mix escript.build; cat sample | ./ls_proxy`?
`mix escript.build; cat /tmp/sample | ./ls_proxy |head`
`ln -s real_language_server.sh language_server.sh`
`curl -H "Content-Type: application/json" --data '{"message": "hihi", "direction": "incoming"}' http://localhost:4001/api/messages`
`env LS_PROXY_TO=none iex -S mix`
```
# maybe env MIX_ENV=prod LS_HTTP_PROXY_TO='http://localhost:4000/api/messages' mix escript.build; cp app /tmp/ls_proxy_release/language_server.sh
# maybe env MIX_ENV=prod mix escript.build; cp app /tmp/ls_proxy_release/language_server.sh

cd ~/dev/forks/vscode-elixir-ls/
git checkout ls-proxy
vsce package
code --install-extension ./elixir-ls-0.3.1.vsix  --force
code
```

# Files

* `sample` is sample input
* `shell_proxy.sh` - A pure-shell proxy that logs output
* `ls_proxy.sh` - adds some debugging then calls ls_proxy
* `ls_proxy` - the actual elixir ls_proxy built as an escript


Updating vscode plugins

Can't uninstall and reinstall in one go

via the gui:
* uninstall
* close program
* install

If you uninstall and then install without restarting, the OLD code is loaded!?

via the command line:
* `code --install-extension ./elixir-ls-0.4.24.vsix`

(Note: if you uninstall and reinstall via command line, the OLD code is loaded!)
