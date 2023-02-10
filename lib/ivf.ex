defmodule Ivf do
  @moduledoc """
  Collection of convenience functions to work with IVF files as described here: https://wiki.multimedia.cx/index.php/Duck_IVF.
  """

  @doc """
  Open an IVF file and lazy stream all frames.

      iex> {props, stream} = Ivf.stream!("test/videos/test_vp8.ivf")
      iex> props
      %Ivf.Props{
        width: 320,
        height: 180,
        tb_num: 1,
        tb_den: 5,
        frame_count: 280,
        codec: "VP80"
      }
      iex> stream |> Enum.to_list |> length
      280
  """
  def stream!(file) when is_pid(file), do: Ivf.Stream.init(file)

  def stream!(file_path) when is_binary(file_path),
    do: File.open!(file_path, [:binary, :read]) |> Ivf.Stream.init()

  @doc """
  Create a new IVF file.
  """
  def write!(file, props) when is_pid(file), do: Ivf.Writer.init(file, props)

  def write!(file_path, props) when is_binary(file_path),
    do: File.open!(file_path, [:binary, :write]) |> Ivf.Writer.init(props)

  @doc """
  Append all packets to an new IVF file.
  """
  def append_all(writer = %Ivf.Writer{}, packets, close_file \\ false) do
    writer =
      packets
      |> Enum.reduce(writer, fn packet, writer ->
        Ivf.Writer.append(writer, packet)
      end)

    if close_file, do: Ivf.Writer.close(writer), else: writer
  end
end
