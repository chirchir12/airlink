# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :airlink,
  ecto_repos: [Airlink.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :airlink, AirlinkWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: AirlinkWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Airlink.PubSub,
  live_view: [signing_salt: "hevEII1Q"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :airlink, Airlink.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :airlink, :basic_auth,
  username: System.get_env("AIRLINK_METRICS_AUTH_USERNAME") || "default_username",
  password: System.get_env("AIRLINK_METRICS_AUTH_PASSWORD") || "default_password"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
