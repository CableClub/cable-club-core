defmodule CableClub.MixProject do
  use Mix.Project

  @app :cableclub

  def project do
    [
      app: @app,
      version: "0.1.0",
      elixir: "~> 1.7",
      commit: commit(),
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      releases: [{@app, release()}],
      aliases: aliases(),
      deps: deps()
    ]
  end

  defp commit do
    System.get_env("COMMIT") ||
      System.cmd("git", ~w"rev-parse --verify HEAD", [])
      |> elem(0)
      |> String.trim()
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {CableClub.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:bcrypt_elixir, "~> 2.0"},
      {:phoenix, "~> 1.5.9"},
      {:phoenix_ecto, "~> 4.1"},
      {:ecto_sql, "~> 3.4"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_live_view, "~> 0.15.1"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, "~> 0.4"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:ring_logger, "~> 0.8.1"},
      {:tesla, "~> 1.4"},
      {:hackney, "~> 1.17"},
      {:phx_gen_auth, "~> 0.7.0", only: :dev},
      {:tortoise, "~> 0.9.8"},
      {:circuits_uart, "~> 1.4"},
      {:binpp, "~> 1.1"},
      {:phoenix_markdown, "~> 1.0"},
      {:earmark, "~> 1.4"},
      {:html_entities, "~> 0.5.2"},
      {:slipstream, "~> 0.5"},
      {:cowlib, "~> 2.11", override: true}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end

  defp release do
    [
      overwrite: true,
      include_executables_for: [:unix],
      strip_beams: [keep: ["Docs"]],
      applications: [runtime_tools: :permanent],
      steps: [:assemble],
      cookie: "aHR0cHM6Ly9kaXNjb3JkLmdnL25tOENFVDJNc1A="
    ]
  end
end
