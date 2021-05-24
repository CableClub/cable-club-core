defmodule CableClub.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CableClub.Accounts` context.
  """

  def unique_discord_id, do: System.unique_integer([:positive])
  def unique_user_email, do: "user#{System.unique_integer()}@example.com"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      "id" => unique_discord_id(),
      "email" => unique_user_email()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> CableClub.Accounts.oauth_discord_register_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token, _] = String.split(captured.body, "[TOKEN]")
    token
  end
end
