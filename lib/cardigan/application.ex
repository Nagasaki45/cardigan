defmodule Cardigan.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      CardiganWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Cardigan.PubSub},
      # Start the Endpoint (http/https)
      CardiganWeb.Endpoint,
      # Start a worker by calling: Cardigan.Worker.start_link(arg)
      # {Cardigan.Worker, arg}
      {Registry, keys: :unique, name: Cardigan.TableRegistry},
      {DynamicSupervisor, name: Cardigan.TableSupervisor, strategy: :one_for_one}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Cardigan.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    CardiganWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
