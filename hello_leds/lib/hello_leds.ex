defmodule HelloLeds.Periodically do
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
    require Logger
    Logger.info("Messing with the LEDs.")
    [led_key] = Application.get_env(:hello_leds, :led_list)
    [on_duration | _] = [200, 400, 600, 800, 1000, 1200, 1400, 1600, 1800, 2000]
    [off_duration | _] = [100, 300, 500, 700, 900, 1100, 1300, 1500, 1700, 1900] |> Enum.shuffle
    Logger.info("Messing with the LEDs.\nOn Duration: #{on_duration}\nOff Duration: #{off_duration}")
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

    {:noreply, state}
  end

  defp schedule_work do
    Process.send_after(self(), :work, 1000 * 60)
  end
end
defmodule HelloLeds do
  @moduledoc """
  Simple example to blink a list of LEDs forever.

  The list of LEDs is platform-dependent, and defined in the config
  directory (see config.exs).   See README.md for build instructions.
  """

  # Durations are in milliseconds
  @on_duration 200
  @off_duration 50

  alias Nerves.Leds
  require Logger

  def start(_type, _args) do
    led_list = Application.get_env(:hello_leds, :led_list)
    Logger.debug("list of leds to blink is #{inspect(led_list)}")
    Enum.each(led_list, &start_blink(&1))
    {:ok, self()}
  end

  # Set led `led_key` to the state defined below. It is also possible
  # to globally define states in `config/config.exs` by passing a list
  # of states with the `:states` keyword.
  #
  # The first parameter must be an atom.
  @spec start_blink(Keyword.T) :: true
  defp start_blink(led_key) do
    Logger.debug("blinking led #{inspect(led_key)}")
    # led_key is a variable that contains an atom
    Leds.set([
      {
        led_key,
        [
          trigger: "timer",
          delay_off: @off_duration,
          delay_on: @on_duration
        ]
      }
    ])
    HelloLeds.Periodically.start_link
  end
end
