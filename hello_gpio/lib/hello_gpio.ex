defmodule HelloGpio do
  use Application

  require Logger

  alias Circuits.GPIO

  @output_pin Application.get_env(:hello_gpio, :output_pin, 26)
  @input_pin Application.get_env(:hello_gpio, :input_pin, 20)

  def start(_type, _args) do
    Logger.info("Starting pin #{@output_pin} as output")
    {:ok, output_gpio} = GPIO.open(@output_pin, :output)
    spawn(fn -> toggle_pin_forever(output_gpio) end)

    Logger.info("Starting pin #{@input_pin} as input")
    {:ok, input_gpio} = GPIO.open(@input_pin, :input)
    spawn(fn -> listen_forever(input_gpio) end)
    {:ok, self()}
  end

  defp toggle_pin_forever(output_gpio) do
    Logger.debug("Turning pin #{@output_pin} ON")
    GPIO.write(output_gpio, 1)
    Process.sleep(500)

    Logger.debug("Turning pin #{@output_pin} OFF")
    GPIO.write(output_gpio, 0)
    Process.sleep(500)

    toggle_pin_forever(output_gpio)
  end

  defp listen_forever(input_gpio) do
    # Start listening for interrupts on rising and falling edges
    GPIO.set_interrupts(input_gpio, :both)
    listen_loop()
  end

  defp listen_loop() do
    # Infinite loop receiving interrupts from gpio
    receive do
      {:circuits_gpio, p, _timestamp, 1} ->
        Logger.debug("Received rising event on pin #{p}")

      {:circuits_gpio, p, _timestamp, 0} ->
        Logger.debug("Received falling event on pin #{p}")
    end

    listen_loop()
  end
end
