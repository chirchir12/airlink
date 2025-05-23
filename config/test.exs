import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :airlink, Airlink.Repo,
  username: System.get_env("AIRLINK_DB_TEST_USERNAME") || "postgres",
  password: System.get_env("AIRLINK_DB_TEST_PASSWORD") || "postgres",
  hostname: System.get_env("AIRLINK_DB_TEST_HOST") || "localhost",
  database: System.get_env("AIRLINK_DB_TEST_DATABASE") || "postgres",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :airlink, AirlinkWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 8002],
  secret_key_base: "foqO1mc+FqM/19bA2fz8WK1wvABRUngpKQHMN/lqC6S5q2vCLvM0JuT8JyOuid1Q",
  server: false

# In test we don't send emails.
config :airlink, Airlink.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  # Enable helpful, but potentially expensive runtime checks
  enable_expensive_runtime_checks: true
