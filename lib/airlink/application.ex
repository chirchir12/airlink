defmodule Airlink.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AirlinkWeb.Telemetry,
      Airlink.Repo,
      Airlink.Companies.CompanyServer,
      Airlink.Routers.RouterServer,
      Airlink.Subscriptions.SubscriptionConsumer,
      Airlink.Payments.PaymentConsumer,
      Airlink.Companies.CompanyConsumer,
      Airlink.RmqPulbisher,
      {DNSCluster, query: Application.get_env(:airlink, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Airlink.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Airlink.Finch},
      # Start a worker by calling: Airlink.Worker.start_link(arg)
      # {Airlink.Worker, arg},
      # Start to serve requests, typically the last entry
      AirlinkWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Airlink.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AirlinkWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
