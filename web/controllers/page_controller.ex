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

  defp parse(conn, path) do
    Logger.debug "Path: “#{inspect path}”"
    with [path | _collection] <- :lists.reverse(path),
         links <- Eblox.GenEblox.get(path),
         {ast, acc} <- (links[:path] |> File.read! |> Markright.to_ast(Eblox.Markright.Collector)) do
      conn
      |> assign(:prev_link, links[:prev])
      |> assign(:next_link, links[:next])
      |> assign(:acc, acc)
      |> assign(:content, XmlBuilder.generate(ast))
    end
  end
end
