import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :simple_elixir_server, SimpleElixirServer.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "simple_elixir_server_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :simple_elixir_server_web, SimpleElixirServerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "LKl3fs10KwTkKYiYB6tkh2D/DcboZpho+Oru6XhDvvxSGYQou+PYsiwsQ/o99n6m",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# In test we don't send emails
config :simple_elixir_server, SimpleElixirServer.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
