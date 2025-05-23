import Config

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: Airlink.Finch

# Disable Swoosh Local Memory Storage
config :swoosh, local: false

# Do not print debug messages in production
config :logger, level: :info

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.
config :airlink, AirlinkWeb.Endpoint, check_origin: false

config :airlink, :basic_auth,
  username: System.get_env("AIRLINK_METRICS_AUTH_USERNAME"),
  password: System.get_env("AIRLINK_METRICS_AUTH_PASSWORD")
