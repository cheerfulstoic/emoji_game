defmodule EmojiGame.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {TelemetryMetricsStatsd, EmojiGameWeb.Telemetry.metrics_statsd_options()},

      {DynamicSupervisor, strategy: :one_for_one, name: EmojiGame.ActorSupervisor},
      {Task.Supervisor, name: EmojiGame.TaskSupervisor},

      EmojiGame.Game,

      # Start the Ecto repository
      EmojiGame.Repo,
      # Start the Telemetry supervisor
      # EmojiGameWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: EmojiGame.PubSub},
      # Start the Endpoint (http/https)
      EmojiGameWeb.Endpoint
      # Start a worker by calling: EmojiGame.Worker.start_link(arg)
      # {EmojiGame.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: EmojiGame.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    EmojiGameWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
