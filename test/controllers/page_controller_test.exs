defmodule Eblox.PageControllerTest do
  use Eblox.Web.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "<link rel=\"stylesheet\" href=\"/css/app.css\">"
  end
end
