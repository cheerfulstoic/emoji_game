defmodule EmojiGameWeb.Telemetry do
  use Supervisor
  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      # Telemetry poller will execute the given period measurements
      # every 10_000ms. Learn more here: https://hexdocs.pm/telemetry_metrics
      {:telemetry_poller, measurements: periodic_measurements(), period: 2_000}
      # Add reporters as children of your supervision tree.
      # {Telemetry.Metrics.ConsoleReporter, metrics: metrics()}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def metrics do
    [
      # Game Metrics
      summary("emoji_game.game.queue.length"),
      summary("emoji_game.actor.move_time.stop.duration", reporter_options: [prune_threshold: 50] ,unit: {:native, :millisecond}),

      # Phoenix Metrics
      summary("phoenix.endpoint.stop.duration",
        unit: {:native, :millisecond}
      ),
      summary("phoenix.router_dispatch.stop.duration",
        tags: [:route],
        unit: {:native, :millisecond}
      ),

      # Database Metrics
      summary("emoji_game.repo.query.total_time", unit: {:native, :millisecond}),
      summary("emoji_game.repo.query.decode_time", unit: {:native, :millisecond}),
      summary("emoji_game.repo.query.query_time", unit: {:native, :millisecond}),
      summary("emoji_game.repo.query.queue_time", unit: {:native, :millisecond}),
      summary("emoji_game.repo.query.idle_time", unit: {:native, :millisecond}),


      # VM Metrics
      summary("vm.memory.total", unit: {:byte, :kilobyte}),
      summary("vm.total_run_queue_lengths.total"),
      summary("vm.total_run_queue_lengths.cpu"),
      summary("vm.total_run_queue_lengths.io")

    ]
  end

  def metrics_statsd_options do
    [
      metrics: [
        summary("emoji_game.game.queue.length"),
        summary("emoji_game.actor.move_time.stop.duration", unit: {:native, :millisecond}),
      ]
    ]
  end

  defp periodic_measurements do
    [
      # A module, function and arguments to be invoked periodically.
      # This function must call :telemetry.execute/3 and a metric must be added above.
      # {EmojiGame.Game, :report_metrics, []}
    ]
  end
end
