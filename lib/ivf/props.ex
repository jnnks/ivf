defmodule Ivf.Props do
  @moduledoc """
  Properties of an Ivf video. Use `Ivf.Props.new(keyword())`.
  """

  @enforce_keys [:width, :height, :time_base, :frame_count, :codec]
  defstruct [:width, :height, :time_base, :frame_count, :codec]

  @spec new(
          codec: binary(),
          frame_count: pos_integer(),
          height: pos_integer(),
          time_base: {pos_integer(), pos_integer()},
          width: pos_integer()
        ) :: %Ivf.Props{}
  def new(opts),
    do: %Ivf.Props{
      width: opts[:width] || 16,
      height: opts[:height] || 16,
      time_base: opts[:time_base] || {1, 1},
      frame_count: opts[:frame_count] || 1,
      codec: opts[:codec] || "VP08"
    }
end
