defmodule CableClubWeb.DocsController do
  use CableClubWeb, :controller

  def pokemon_gen1_link(conn, _params) do
    render(conn, "pokemon.gen1.link.html", [])
  end

  def pokemon_gen1_channel(conn, _params) do
    render(conn, "pokemon.gen1.channel.html")
  end
end
