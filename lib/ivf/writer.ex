
defmodule Ivf.Writer do

  defstruct [:file, :props, frame_count: 0]

  def init(file, props = %Ivf.Props{}) do
    with :ok <- IO.binwrite(file, "DKIF"),
         :ok <- IO.binwrite(file, <<0, 0>>),
         :ok <- IO.binwrite(file, <<32, 0>>),
         :ok <- IO.binwrite(file, props.codec),
         :ok <- IO.binwrite(file, <<props.width::16-little>>),
         :ok <- IO.binwrite(file, <<props.height::16-little>>),
         :ok <- IO.binwrite(file, <<props.tb_den::32-little>>),
         :ok <- IO.binwrite(file, <<props.tb_num::32-little>>),
         :ok <- IO.binwrite(file, <<props.frame_count::32-little>>),
         :ok <- IO.binwrite(file, <<0::32>>) do
      %Ivf.Writer{file: file, props: props}
    else
      error -> error
    end
  end

  def append(writer = %Ivf.Writer{file: file, frame_count: fc}, {timestamp, packet}) do
    :ok = IO.binwrite(file, <<byte_size(packet)::32-little>>)
    :ok = IO.binwrite(file, <<timestamp::64-little>>)
    :ok = IO.binwrite(file, packet)
    %Ivf.Writer{writer | frame_count: fc + 1}
  end

  def append(writer = %Ivf.Writer{frame_count: fc}, packet), do: append(writer, {fc, packet})

  def close(_writer = %Ivf.Writer{file: file, frame_count: fc}) do
    with :ok <- :file.pwrite(file, {:bof, 24}, <<fc::32-little>>),
         :ok <- File.close(file) do
          :ok
         else
          error -> error
         end
  end
end
