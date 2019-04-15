# LsProxy

Proxy for [Language Server](https://microsoft.github.io/language-server-protocol/)'s.

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

# TODO

- [x] parse basic messages
- [x] work transparently but with some logging
- [ ] move to poncho style project and create a phoenix web server

Once published, the docs can be found at
[https://hexdocs.pm/ls_proxy](https://hexdocs.pm/ls_proxy).

Related:
* https://github.com/Microsoft/language-server-protocol-inspector

Future Features:
* Render a web page showing the features that the server supports
* Support TCP sockets? Is that even part of LSP?
