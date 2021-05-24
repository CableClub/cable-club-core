defmodule CableClubWeb.UserSettingsControllerTest do
  use CableClubWeb.ConnCase, async: true

  # alias CableClub.Accounts
  # import CableClub.AccountsFixtures

  setup :register_and_log_in_user

  describe "GET /users/settings" do
    test "renders settings page", %{conn: conn} do
      conn = get(conn, Routes.user_settings_path(conn, :edit))
      response = html_response(conn, 200)
      assert response =~ "Settings"
    end

    test "redirects if user is not logged in" do
      conn = build_conn()
      conn = get(conn, Routes.user_settings_path(conn, :edit))
      assert redirected_to(conn)
    end
  end

  # describe "PUT /users/settings (change email form)" do
  #   @tag :capture_log
  #   test "updates the user email", %{conn: conn, user: user} do
  #     conn =
  #       put(conn, Routes.user_settings_path(conn, :update), %{
  #         "action" => "update_email",
  #         "current_password" => valid_user_password(),
  #         "user" => %{"email" => unique_user_email()}
  #       })

  #     assert redirected_to(conn) == Routes.user_settings_path(conn, :edit)
  #     assert get_flash(conn, :info) =~ "A link to confirm your email"
  #     assert Accounts.get_user_by_email(user.email)
  #   end

  #   test "does not update email on invalid data", %{conn: conn} do
  #     conn =
  #       put(conn, Routes.user_settings_path(conn, :update), %{
  #         "action" => "update_email",
  #         "current_password" => "invalid",
  #         "user" => %{"email" => "with spaces"}
  #       })

  #     response = html_response(conn, 200)
  #     assert response =~ "<h1>Settings</h1>"
  #     assert response =~ "must have the @ sign and no spaces"
  #     assert response =~ "is not valid"
  #   end
  # end
end
