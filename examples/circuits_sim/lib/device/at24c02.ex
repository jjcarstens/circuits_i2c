defmodule CircuitsSim.Device.AT24C02 do
  @moduledoc """
  This is a 2 Kb (256 byte) I2C EEPROM

  This does not implementing the paging, so it's forgiving of writes across
  EEPROM write pages. If you use a real AT24C02, make sure not to cross 8-byte
  boundaries when writing more than one byte.
  """
  alias CircuitsSim.SimpleI2C

  defstruct [:contents]
  @type t() :: %__MODULE__{contents: tuple()}

  @spec new() :: t()
  def new() do
    %__MODULE__{contents: Tuple.duplicate(0xFF, 256)}
  end

  defimpl SimpleI2C do
    @impl SimpleI2C
    def write_register(state, reg, value) do
      %{state | contents: put_elem(state.contents, reg, value)}
    end

    @impl SimpleI2C
    def read_register(state, reg) do
      {elem(state.contents, reg), state}
    end

    defp hex(x) do
      [
        Integer.to_string(div(x, 16)),
        Integer.to_string(rem(x, 16))
      ]
    end

    @impl SimpleI2C
    def render(state) do
      header = for i <- 0..15, do: [Integer.to_string(i, 16), "  "]

      [
        "  ",
        header,
        "\n",
        for i <- 0..255 do
          v = elem(state.contents, i)
          term = if rem(i, 16) == 15, do: "\n", else: " "
          [hex(v), term]
        end
      ]
    end

    @impl SimpleI2C
    def handle_message(state, _message) do
      state
    end
  end
end
