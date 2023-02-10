
defmodule Ivf.Stream do
  defstruct [:file]

  def init(file) do
    {decode_header(file), %Ivf.Stream{file: file}}
  end

  defp decode_header(file) do
    with "DKIF" <- IO.binread(file, 4),
         <<0, 0>> <- IO.binread(file, 2),
         <<32, 0>> <- IO.binread(file, 2),
         codec <- IO.binread(file, 4),
         <<width::16-little>> <- IO.binread(file, 2),
         <<height::16-little>> <- IO.binread(file, 2),
         <<tb_den::32-little>> <- IO.binread(file, 4),
         <<tb_num::32-little>> <- IO.binread(file, 4),
         <<frame_count::32-little>> <- IO.binread(file, 4),
         <<_unused_zeroes::32>> <- IO.binread(file, 4) do
      %Ivf.Props{
        codec: codec,
        width: width,
        height: height,
        tb_den: tb_den,
        tb_num: tb_num,
        frame_count: frame_count
      }
    else
      _ -> raise RuntimeError, "malformed file header"
    end
  end
end

defimpl Enumerable, for: Ivf.Stream do
  def count(_), do: raise(RuntimeError, "Ivf.Stream only supports reduce")
  def slice(_), do: raise(RuntimeError, "Ivf.Stream only supports reduce")
  def member?(_, _), do: raise(RuntimeError, "Ivf.Stream only supports reduce")

  def reduce(_list, {:halt, acc}, _fun), do: {:halted, acc}

  def reduce(stream = %Ivf.Stream{}, {:suspend, acc}, fun),
    do: {:suspended, acc, &reduce(stream, &1, fun)}

  def reduce([], {:cont, acc}, _fun), do: {:done, acc}

  def reduce(stream = %Ivf.Stream{file: file}, {:cont, acc}, fun) do
    with <<len::size(32)-little>> <- IO.binread(file, 4),
         <<timestamp::size(64)-little>> <- IO.binread(file, 8),
         frame <- IO.binread(file, len) do
      reduce(stream, fun.({timestamp, frame}, acc), fun)
    else
      :eof ->
        File.close(file)
        {:done, acc}
    end
  end
end
