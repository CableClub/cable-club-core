defmodule CableClub.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Inspect, except: [:password]}
  schema "users" do
    field :discord_user_id, Snowflake
    field :email, :string
    field :confirmed_at, :naive_datetime
    field :roles, {:array, Ecto.Enum}, values: [:admin, :library], default: []

    embeds_one :discord_oauth_info, DiscordInfo, on_replace: :delete do
      field :username, :string
      field :avatar, :string
      field :discriminator, :string
    end

    timestamps()
  end

  def validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> unsafe_validate_unique(:email, CableClub.Repo)
    |> unique_constraint(:email)
  end

  def oauth_registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :discord_user_id])
    |> validate_required([:discord_user_id])
    |> cast_embed(:discord_oauth_info, required: true, with: &child_changeset/2)
    |> unique_constraint(:discord_user_id)

    # |> validate_email()
  end

  def child_changeset(discord_oauth_info, attrs) do
    discord_oauth_info
    |> cast(attrs, [:username, :avatar, :discriminator])
    |> validate_required([])
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    change(user, confirmed_at: now)
  end
end
