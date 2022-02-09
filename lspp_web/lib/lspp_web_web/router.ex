defmodule LsppWebWeb.Router do
  use LsppWebWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_root_layout, {LsppWebWeb.LayoutView, :root}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LsppWebWeb do
    pipe_through :browser

    live "/", DashboardLive
  end

  if Application.fetch_env!(:lspp_web, :static_assets) == :static do
    get "/assets/app.css", LsppWebWeb.StaticAssetController, :app_css
    get "/assets/app.js", LsppWebWeb.StaticAssetController, :app_js
    get "/images/phoenix.png", LsppWebWeb.StaticAssetController, :phoenix_png
  end

  scope "/api", LsppWebWeb do
    pipe_through :api

    post "/messages", MessagesController, :create
    post "/incoming_messages", MessagesController, :incoming
    post "/outgoing_messages", MessagesController, :outgoing
  end
end
