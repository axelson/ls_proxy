defmodule LsppWebWeb.StaticAssetController do
  use LsppWebWeb, :controller

  @static_dir :code.priv_dir(:lspp_web) |> to_string() |> Path.join("static")
  @app_css File.read!(Path.join(@static_dir, "css/app.css"))
  @app_js File.read!(Path.join(@static_dir, "js/app.js"))
  @phoenix_png File.read!(Path.join(@static_dir, "images/phoenix.png"))

  def app_css(conn, _params) do
    conn
    |> Plug.Conn.put_resp_content_type("text/css")
    |> Plug.Conn.send_resp(200, @app_css)
  end

  def app_js(conn, _params) do
    conn
    |> Plug.Conn.put_resp_content_type("application/js")
    |> Plug.Conn.send_resp(200, @app_js)
  end

  def phoenix_png(conn, _params) do
    conn
    |> Plug.Conn.send_resp(200, @phoenix_png)
  end
end
