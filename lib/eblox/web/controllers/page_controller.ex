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
    |> assign(:description, @description)
    |> assign(:author, @author)
    |> assign(:prev_title, "⇐")
    |> assign(:next_title, "⇒")
    |> prepare()
    |> thumbnails()
  end

  defp prepare(conn) do
    parse(conn, conn.path_info)
  end

  defp thumbnails(conn) do
    assign(conn, :thumbnails, Eblox.GenEblox.random())
  end

  defp parse(conn, []), do: parse(conn, [nil])
  defp parse(conn, path) when is_list(path) do
    with [path | _collection] <- :lists.reverse(path),
         %Eblox.Content{title: title} = content <- Eblox.GenEblox.get(path) do
      title = if title, do: [XmlBuilder.generate(title)], else: path

      conn
      |> assign(:content, content)
      |> assign(:title, Enum.join([@title | title], " ⇒ "))
    end
  end
end
