defmodule Eblox.Web.PageController do
  use Eblox.Web, :controller
  require Logger

  plug :generic_route

  def index(conn, _params) do
    render conn, "index.html"
  end

  defp generic_route(conn, _opts) do
    conn
    |> put_flash(:info, "You must be logged in")
    |> assign(:title, "Hello EBLOX")
    |> assign(:description, "Hello EBLOX")
    |> assign(:author, "Aleksei Matiushkin")
    |> assign(:prev_title, "⇐")
    |> assign(:next_title, "⇒")
    |> prepare
  end

  defp prepare(conn) do
    parse(conn, conn.path_info)
  end

  defp parse(conn, []), do: parse(conn, [nil])
  defp parse(conn, path) when is_list(path) do
    with [path | _collection] <- :lists.reverse(path),
         %Eblox.Content{} = content <- Eblox.GenEblox.get(path) do
      assign(conn, :content, content)
    end
  end
end
