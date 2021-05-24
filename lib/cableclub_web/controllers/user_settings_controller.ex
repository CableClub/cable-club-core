defmodule CableClubWeb.UserSettingsController do
  use CableClubWeb, :controller

  def edit(conn, _params) do
    render(conn, "edit.html")
  end

  def update(conn, _params) do
    render(conn, "edit.html")
  end
end
