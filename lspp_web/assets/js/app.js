import {Socket} from "phoenix"
import LiveSocket from "phoenix_live_view"

console.log("in app.js")
// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}});
liveSocket.connect()
