defmodule Lynx.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    ash_domains = Application.fetch_env!(:lynx, :ash_domains)

    children = [
      LynxWeb.Telemetry,
      Lynx.Repo,
      {DNSCluster, query: Application.get_env(:lynx, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Lynx.PubSub},
      {Finch, name: Lynx.Finch},
      {AshAuthentication.Supervisor, otp_app: :lynx},
      {Oban, AshOban.config(ash_domains, Application.fetch_env!(:lynx, Oban))},
      # Start to serve requests, typically the last entry
      LynxWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Lynx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LynxWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
