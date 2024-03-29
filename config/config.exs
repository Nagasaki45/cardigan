# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :cardigan, CardiganWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Qdp3QD3KKzYrCbYr12IllyP8YKIyfBGP8OkC7cvQtIKfOZnbQ0r1aacvNt/tjSyy",
  render_errors: [view: CardiganWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Cardigan.PubSub,
  live_view: [signing_salt: "vJ2Iy2AD"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
