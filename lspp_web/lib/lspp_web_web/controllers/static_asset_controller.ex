defmodule LsppWebWeb.StaticAssetController do
  use LsppWebWeb, :controller

  # Maybe the "static" part of this should be in app, that way the webpack code is already run?
  @static_dir :code.priv_dir(:lspp_web) |> to_string() |> Path.join("static")
  @app_css File.read(Path.join(@static_dir, "assets/app.css"))
  @app_js File.read(Path.join(@static_dir, "assets/app.js"))

  @images_dir Path.join([__DIR__, "..", "assets", "static", "images"])
  @phoenix_png File.read(Path.join(@images_dir, "phoenix.png"))

  def app_css(conn, _params) do
    conn
    |> Plug.Conn.put_resp_content_type("text/css")
    |> Plug.Conn.send_resp(200, read_file(@app_css))
  end

  def app_js(conn, _params) do
    conn
    |> Plug.Conn.put_resp_content_type("application/js")
    |> Plug.Conn.send_resp(200, read_file(@app_js))
  end

  def phoenix_png(conn, _params) do
    conn
    |> Plug.Conn.send_resp(200, read_file(@phoenix_png))
  end

  def read_file({:ok, contents}), do: contents
  def read_file(_), do: ""
end
