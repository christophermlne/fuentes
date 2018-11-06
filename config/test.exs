use Mix.Config

config :fuentes, ecto_repos: [Fuentes.TestRepo]

config :fuentes, Fuentes.TestRepo,
  hostname: "localhost",
  database: "fuentes_test",
  username: "postgres",
  password: "postgres",
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox,
  port: 5437

config :logger, level: :warn
