defmodule CableClubWeb.OAuth.Discord do
  @client_id Application.get_env(:cableclub, __MODULE__)[:client_id]
  @client_secret Application.get_env(:cableclub, __MODULE__)[:client_secret]
  @url Application.get_env(:cableclub, __MODULE__)[:url]
  @url ||
    Mix.raise("""
    OAuth URL unconfigured
    """)

  use Tesla
  require Logger
  plug Tesla.Middleware.Logger
  plug Tesla.Middleware.BaseUrl, "https://discord.com/api/v8"
  plug Tesla.Middleware.Headers, []
  plug Tesla.Middleware.FormUrlencoded
  plug Tesla.Middleware.FollowRedirects

  def redirect_uri, do: @url
  def link_redirect_uri, do: "http://localhost:4000/oauth/discord/link"

  def authorization_url(state \\ "") do
    query =
      URI.encode_query(%{
        "client_id" => @client_id,
        "prompt" => "consent",
        "redirect_uri" => @url,
        "response_type" => "code",
        "scope" => "identify email",
        "state" => state
      })

    %URI{
      authority: "discord.com",
      fragment: nil,
      host: "discord.com",
      path: "/api/oauth2/authorize",
      port: 443,
      query: query,
      scheme: "https",
      userinfo: nil
    }
    |> to_string()
  end

  def link_authorization_url(state \\ "") do
    query =
      URI.encode_query(%{
        "client_id" => @client_id,
        "prompt" => "consent",
        "redirect_uri" => link_redirect_uri(),
        "response_type" => "code",
        "scope" => "identify email",
        "state" => state
      })

    %URI{
      authority: "discord.com",
      fragment: nil,
      host: "discord.com",
      path: "/api/oauth2/authorize",
      port: 443,
      query: query,
      scheme: "https",
      userinfo: nil
    }
    |> to_string()
  end

  def client(%{"access_token" => token, "token_type" => type}) do
    middleware = [
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, [{"Authorization", "#{type} " <> token}]}
    ]

    Tesla.client(middleware)
  end

  # spec from Tesla is wrong
  @dialyzer {:nowarn_function, {:exchange_code, 2}}
  def exchange_code(redirect_uri, code) do
    response =
      post!("/oauth2/token", %{
        client_id: @client_id,
        client_secret: @client_secret,
        grant_type: "authorization_code",
        code: code,
        redirect_uri: redirect_uri,
        scope: "identify email"
      })

    Logger.info("exchange_code: #{code} => #{inspect(response)}")

    with %Tesla.Env{status: 200} = env <- response,
         {:ok, %Tesla.Env{body: body}} <- Tesla.Middleware.JSON.decode(env, []) do
      # refresh_token(body)
      client(body)
    else
      %Tesla.Env{} = env ->
        {:ok, env} = Tesla.Middleware.JSON.decode(env, [])
        raise inspect(env.body)
    end
  end

  @dialyzer {:nowarn_function, {:refresh_token, 1}}
  def refresh_token(%{"refresh_token" => refresh_token} = body) do
    response =
      post!(client(body), "/oauth2/token", %{
        client_id: @client_id,
        client_secret: @client_secret,
        grant_type: "refresh_token",
        refresh_token: refresh_token,
        redirect_uri: @url,
        scope: "identify email connections"
      })

    Logger.info("refresh token => #{inspect(response)}")

    with %Tesla.Env{status: 200} = env <- response,
         {:ok, %Tesla.Env{body: body}} <- Tesla.Middleware.JSON.decode(env, []) do
      # {client(body), body}
      client(body)
    else
      %Tesla.Env{} = env ->
        {:ok, env} = Tesla.Middleware.JSON.decode(env, [])
        raise inspect(env.body)
    end
  end

  def me(client) do
    case get(client, "/users/@me", query: []) do
      {:ok, %Tesla.Env{body: body}} -> {:ok, body}
      error -> error
    end
  end
end
