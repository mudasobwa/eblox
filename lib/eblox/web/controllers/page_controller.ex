defmodule Eblox.Web.PageController do
  use Eblox.Web, :controller
  require Logger

  plug :generic_route

  @title Application.get_env(:eblox, :title, "Ebl❤x")
  @description Application.get_env(:eblox, :description, "Ebl❤x")
  @author Application.get_env(:eblox, :author, "Aleksei Matiushkin")

  def index(conn, _params) do
    render conn, "index.html"
  end

  defp generic_route(conn, _opts) do
    conn
    # TODO |> put_flash(:info, "You must be logged in")
    |> assign(:title, @title)
    |> assign(:description, @description)
    |> assign(:author, @author)
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
