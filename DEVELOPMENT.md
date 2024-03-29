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
`env MIX_ENV=prod LS_HTTP_PROXY_TO='http://localhost:4000/api/messages' mix escript.build && ./install-vscode.bash`

`mix escript.build`?
`mix escript.build; cat sample | ./ls_proxy`?
`mix escript.build; cat /tmp/sample | ./ls_proxy |head`
`ln -s real_language_server.sh language_server.sh`
`curl -H "Content-Type: application/json" --data '{"message": "hihi", "direction": "incoming"}' http://localhost:4001/api/messages`
`env LS_PROXY_TO=none iex -S mix`

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
