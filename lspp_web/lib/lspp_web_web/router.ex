defmodule LsppWebWeb.Router do
  use LsppWebWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LsppWebWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  get "/css/app.css", LsppWebWeb.StaticAssetController, :app_css
  get "/js/app.js", LsppWebWeb.StaticAssetController, :app_js
  get "/images/phoenix.png", LsppWebWeb.StaticAssetController, :phoenix_png

  # Other scopes may use custom stacks.
  # scope "/api", LsppWebWeb do
  #   pipe_through :api
  # end
end
