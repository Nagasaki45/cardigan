defmodule Gamixir.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      GamixirWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Gamixir.PubSub},
      # Start the Endpoint (http/https)
      GamixirWeb.Endpoint,
      # Start a worker by calling: Gamixir.Worker.start_link(arg)
      # {Gamixir.Worker, arg}
      {Registry, keys: :unique, name: Gamixir.TableRegistry},
      {DynamicSupervisor, name: Gamixir.TableSupervisor, strategy: :one_for_one}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Gamixir.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    GamixirWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
