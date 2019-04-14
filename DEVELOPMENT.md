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
