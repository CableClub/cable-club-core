defmodule CableClubWeb.DocsController do
  use CableClubWeb, :controller

  def pokemon_gen1_link(conn, _params) do
    render(conn, "link.html", [])
  end
end
