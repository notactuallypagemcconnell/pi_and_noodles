# Pull in Nerves-specific helpers to the IEx session
use Nerves.Runtime.Helpers

defmodule Periodically do
  use GenServer
  alias Nerves.Leds

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, %{})
  end

  @impl true
  def init(state) do
    # Schedule work to be performed on start
    schedule_work()

    {:ok, state}
  end

  @impl true
  def handle_info(:work, state) do
    IO.puts("Messing with the LEDs.")
    [led_key] = Application.get_env(:hello_leds, :led_list)
    [on_duration | _] = [200, 400, 600, 800, 1000, 1200, 1400, 1600, 1800, 2000] [off_duration | _] = [100, 300, 500, 700, 900, 1100, 1300, 1500, 1700, 1900] |> Enum.shuffle
    IO.puts("Messing with the LEDs.\nOn Duration: #{on_duration}\nOff Duration: #{off_duration}")
    Leds.set([
      {
        led_key,
        [
          trigger: "timer",
          delay_off: off_duration,
          delay_on: on_duration
        ]
      }
    ])
    schedule_work()
    require Logger
    Logger.warn("\n\n\nI'm trying to log\n\n\n")
    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :work, 1000 * 10)
  end
end

if RingIO in Application.get_env(:logger, :backends, []) do
  IO.puts """
  RingIO is collecting log messages from Elixir and Linux. To see the
  messages, either attach the current IEx session to the logger:

    RingIO.attach

  or tail the log:

    RingIO.tail
  """
  Periocally.start_link
end


# {:ok, pid} = Periodic.start_link
IO.puts "Not tailing, you should see logs from the app"
Ringlogger.tail
# Be careful when adding to this file. Nearly any error can crash the VM and
# cause a reboot.
