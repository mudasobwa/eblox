defmodule Eblox.Web.Router do
  use Eblox.Web, :router

  pipeline :browser do
    plug Plug.Static,
        at: "/", from: :eblox, gzip: false,
        only: ~w(css fonts images i .well-known js rss favicon.ico favicon.png keybase.txt robots.txt my_fine.html)

    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Eblox.Web do
    pipe_through :browser # Use the default browser stack

    get "/*path", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", Eblox do
  #   pipe_through :api
  # end
end
