
defmodule Ivf.Props do
  defstruct [:width, :height, :tb_num, :tb_den, frame_count: 0, codec: "VP80"]
  def new(), do: %Ivf.Props{}
  def with_resolution(props, width, height), do: %Ivf.Props{props | width: width, height: height}

  def with_time_base(props, tb_num, tb_den),
    do: %Ivf.Props{props | tb_num: tb_num, tb_den: tb_den}
end
