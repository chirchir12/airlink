import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/airlink start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("AIRLINK_PHX_SERVER") do
  config :airlink, AirlinkWeb.Endpoint, server: true
end

if config_env() == :prod do
  database_url =
    System.get_env("AIRLINK_DATABASE_URL") ||
      raise """
      environment variable AIRLINK_DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :airlink, Airlink.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("AIRLINK_SECRET_KEY_BASE") ||
      raise """
      environment variable AIRLINK_SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("AIRLINK_PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("AIRLINK_PORT") || "4002")

  config :airlink, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :airlink, AirlinkWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/bandit/Bandit.html#t:options/0
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  # ## SSL Support
  #
  # To get SSL working, you will need to add the `https` key
  # to your endpoint configuration:
  #
  #     config :airlink, AirlinkWeb.Endpoint,
  #       https: [
  #         ...,
  #         port: 443,
  #         cipher_suite: :strong,
  #         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
  #         certfile: System.get_env("SOME_APP_SSL_CERT_PATH")
  #       ]
  #
  # The `cipher_suite` is set to `:strong` to support only the
  # latest and more secure SSL ciphers. This means old browsers
  # and clients may not be supported. You can set it to
  # `:compatible` for wider support.
  #
  # `:keyfile` and `:certfile` expect an absolute path to the key
  # and cert in disk or a relative path inside priv, for example
  # "priv/ssl/server.key". For all supported SSL configuration
  # options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
  #
  # We also recommend setting `force_ssl` in your config/prod.exs,
  # ensuring no data is ever sent via http, always redirecting to https:
  #
  #     config :airlink, AirlinkWeb.Endpoint,
  #       force_ssl: [hsts: true]
  #
  # Check `Plug.SSL` for all available options in `force_ssl`.

  # ## Configuring the mailer
  #
  # In production you need to configure the mailer to use a different adapter.
  # Also, you may need to configure the Swoosh API client of your choice if you
  # are not using SMTP. Here is an example of the configuration:
  #
  #     config :airlink, Airlink.Mailer,
  #       adapter: Swoosh.Adapters.Mailgun,
  #       api_key: System.get_env("MAILGUN_API_KEY"),
  #       domain: System.get_env("MAILGUN_DOMAIN")
  #
  # For this example you need include a HTTP client required by Swoosh API client.
  # Swoosh supports Hackney and Finch out of the box:
  #
  #     config :swoosh, :api_client, Swoosh.ApiClient.Hackney
  #
  # See https://hexdocs.pm/swoosh/Swoosh.html#module-installation for details.
end

# CORS
# CORS
origins = [
  "https://captive.diracloud.com"
]

other_origins = System.get_env("ALLOWED_ORIGINS")
other_origins = if other_origins, do: String.split(other_origins, ","), else: []

config :cors_plug,
  origin: origins,
  credentials: true,
  headers: [
    "Authorization",
    "Content-Type",
    "Accept",
    "Origin",
    "User-Agent",
    # Allow Cookie header
    "Cookie",
    # Allow Set-Cookie header
    "Set-Cookie",
    "x-app-name"
  ],
  methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
  expose: [
    "Authorization",
    "Set-Cookie"
  ],
  max_age: 86400

# captive
config :airlink, :captive,
  # 30 mins
  cookie_ttl: 60 * 30,
  rate_limit: [
    max_requests: 5,
    allowed_window_in_sec: 10,
    sweep_after_in_sec: 60,
    reset_after_in_ms: 1000 * 60
  ],
  base_url: System.get_env("CAPTIVE_BASE_URL") || raise("CAPTIVE_BASE_URL is not set"),
  plans_uri: System.get_env("CAPTIVE_PACKAGES_URL") || raise("CAPTIVE_PACKAGES_URL is not set"),
  login_uri: System.get_env("CAPTIVE_LOGIN_URI") || raise("CAPTIVE_LOGIN_URI is not set"),
  rate_limit_error_uri:
    System.get_env("CAPTIVE_RATE_LIMIT_ERROR") || raise("CAPTIVE_RATE_LIMIT_ERROR is not set"),
  suspended_isp:
    System.get_env("CAPTIVE_SUSPENDED_ISP") || raise("CAPTIVE_SUSPENDED_ISP is not set"),
  validation_error:
    System.get_env("CAPTIVE_ERROR_VALIDATION") || raise("CAPTIVE_ERROR_VALIDATION is not set"),
  company_not_found: System.get_env("CAPTIVE_ERROR_ISP") || raise("CAPTIVE_ERROR_ISP is not set"),
  hotspot_not_found:
    System.get_env("CAPTIVE_ERROR_HOTSPOT") || raise("CAPTIVE_ERROR_HOTSPOT is not set"),
  router_not_found:
    System.get_env("CAPTIVE_ERROR_ROUTER_NOT_FOUND") ||
      raise("CAPTIVE_ERROR_ROUTER_NOT_FOUND is not set")

# Diralink
config :airlink, :diralink,
  base_url: System.get_env("DIRALINK_BASE_URL") || raise("DIRALINK_BASE_URL is not set"),
  username: System.get_env("DIRALINK_API_KEY") || raise("DIRALINK_API_KEY is not set"),
  password: System.get_env("DIRALINK_API_SECRET") || raise("DIRALINK_API_SECRET is not set")

# Radius
config :airlink, :radius,
  base_url: System.get_env("RADIUS_BASE_URL") || raise("RADIUS_BASE_URL is not set")

# MAIN EXCHANGE
exchange_name =
  System.get_env("RMQ_DIRALINK_EXCHANGE") || raise("RMQ_DIRALINK_EXCHANGE is missing")

connection = System.get_env("RMQ_URL") || raise("RMQ_URL environment variable is missing")

# rmq publisher
config :airlink, Airlink.RmqPublisher,
  url: connection,
  exchange: exchange_name

# payment consumer
config :airlink, Airlink.Payments.PaymentConsumer,
  connection: connection,
  exchange: exchange_name,
  deadletter: false,
  queue_options: [
    durable: true
  ],
  queue:
    System.get_env("RMQ_AIRLINK_PAYMENT_RESULT_CONSUMER") ||
      raise("RMQ_AIRLINK_PAYMENT_RESULT_CONSUMER environment variable is missing"),
  prefetch_count: "10",
  routing_key:
    System.get_env("RMQ_PAYMENT_RESULT_ROUTING_KEY") ||
      raise("RMQ_PAYMENT_RESULT_ROUTING_KEY environment variable is missing")

# subscription consumer
config :airlink, Airlink.Subscriptions.SubscriptionConsumer,
  connection: connection,
  exchange: exchange_name,
  deadletter: false,
  queue_options: [
    durable: true
  ],
  queue:
    System.get_env("RMQ_AIRLINK_SUBSCRIPTION_CONSUMER") ||
      raise("RMQ_AIRLINK_SUBSCRIPTION_CONSUMER environment variable is missing"),
  prefetch_count: "10",
  routing_key:
    System.get_env("RMQ_SUBSCRIPTION_ROUTING_KEY") ||
      raise("RMQ_SUBSCRIPTION_ROUTING_KEY environment variable is missing")

# company consumer
config :airlink, Airlink.Companies.CompanyConsumer,
  connection: connection,
  exchange: exchange_name,
  deadletter: false,
  queue_options: [
    durable: true
  ],
  queue:
    System.get_env("RMQ_AIRLINK_COMPANY_CONSUMER") ||
      raise("RMQ_AIRLINK_COMPANY_CONSUMER environment variable is missing"),
  prefetch_count: "10",
  routing_key:
    System.get_env("RMQ_COMPANY_ROUTING_KEY") ||
      raise("RMQ_COMPANY_ROUTING_KEY environment variable is missing")

# router consumer
config :airlink, Airlink.Routers.RouterConsumer,
  connection: connection,
  exchange: exchange_name,
  deadletter: false,
  queue_options: [
    durable: true
  ],
  queue:
    System.get_env("RMQ_AIRLINK_ROUTER_CONSUMER") ||
      raise("RMQ_AIRLINK_ROUTER_CONSUMER environment variable is missing"),
  prefetch_count: "10",
  routing_key:
    System.get_env("RMQ_ROUTER_ROUTING_KEY") ||
      raise("RMQ_ROUTER_ROUTING_KEY environment variable is missing")

# auth
system_secret =
  System.get_env("AIRLINK_SYSTEM_AUTH_SECRET") || raise("AIRLINK_SYSTEM_AUTH_SECRET is not set")

users_secret = System.get_env("AIRLINK_AUTH_SECRET") || raise("AIRLINK_AUTH_SECRET is not set")

config :airlink, Airlink.Diralink.Auth,
  system_secret: Joken.Signer.create("HS512", system_secret),
  users_secret: Joken.Signer.create("HS512", users_secret)

# broadway for handling accounting data
config :airlink, Airlink.AccountingHandler,
  producer: [
    module:
      {BroadwayRabbitMQ.Producer,
       queue:
         System.get_env("RMQ_AIRLINK_ACCOUNTING_CONSUMER") ||
           raise("RMQ_AIRLINK_ACCOUNTING_CONSUMER is missing"),
       bindings: [{exchange_name, []}],
       connection: [
         host: System.get_env("RMQ_HOST") || raise("RMQ_HOST is missing"),
         username: System.get_env("RMQ_USERNAME") || raise("RMQ_USERNAME is missing"),
         password: System.get_env("RMQ_PASSWORD") || raise("RMQ_PASSWORD is missing")
       ],
       on_failure: :reject_and_requeue,
       qos: [
         prefetch_count: 50
       ]},
    concurrency: 1
  ],
  processors: [
    default: [
      concurrency: 10
    ]
  ]
