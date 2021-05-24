defmodule CableClubWeb.PageLiveTest do
  use CableClubWeb.ConnCase

  import Phoenix.LiveViewTest

  test "disconnected and connected render", %{conn: conn} do
    {:ok, page_live, disconnected_html} = live(conn, "/")
    assert disconnected_html
    assert render(page_live)
  end
end
