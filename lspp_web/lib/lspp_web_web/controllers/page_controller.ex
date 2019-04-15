defmodule LsppWebWeb.PageController do
  use LsppWebWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
