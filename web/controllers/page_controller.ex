defmodule Eblox.PageController do
  use Eblox.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
