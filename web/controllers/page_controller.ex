defmodule Eblox.PageController do
  use Eblox.Web, :controller
  require Logger

  plug :generic_route

  def index(conn, _params) do
    render conn, "index.html"
  end

  defp generic_route(conn, _opts) do
    Logger.info inspect(conn.path_info)
    # assign(conn, :user, user)
    conn |> put_flash(:info, "You must be logged in")
#    conn
  end
end
