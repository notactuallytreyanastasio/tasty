defmodule Tasty.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TastyWeb.Telemetry,
      Tasty.Repo,
      {DNSCluster, query: Application.get_env(:tasty, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Tasty.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Tasty.Finch},
      # Start a worker by calling: Tasty.Worker.start_link(arg)
      # {Tasty.Worker, arg},
      # Start to serve requests, typically the last entry
      TastyWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tasty.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TastyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
