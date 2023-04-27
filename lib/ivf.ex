defmodule Ivf do
  @moduledoc """
  Collection of convenience functions to work with IVF files as described here: https://wiki.multimedia.cx/index.php/Duck_IVF.

  ## Reading Files
  ```elixir
  {props, stream} = Ivf.stream!("test/videos/test_vp8.ivf")
  %Ivf.Props{
    width: 320,
    height: 180,
    time_base: {1, 5},
    frame_count: 280,
    codec: "VP80"
  } = props
  200 = stream |> Enum.to_list |> length
  ```
  ____
  ____

  ## Writing Files
  ```elixir
  file = File.open!("test/videos/out.ivf", [:binary, :write])
  writer = Ivf.write!(file, Ivf.Props.new([]))
  # File will not be written to until frames are appended
  {:ok, %File.Stat{size: 0}} = File.stat("test/videos/out.ivf")
  # writer accepts any binary or list
  writer = Ivf.Writer.append(writer, "invalid_test_frame")
  # time stamps can also be provided
  writer = Ivf.Writer.append(writer, {1, "invalid_test_frame"})
  writer = Ivf.Writer.append(writer, {3, "invalid_test_frame"})
  # close the writer, the frame count in the header will be adjusted
  :ok = Ivf.Writer.close(writer)
  ```
  """

  @doc """
  Open an IVF file and lazy stream all frames.
  """
  @spec stream!(binary | pid) :: {Ivf.Props.t(), Stream.t()}
  def stream!(file) when is_pid(file), do: Ivf.Stream.init(file)

  def stream!(file_path) when is_binary(file_path),
    do: File.open!(file_path, [:binary, :read]) |> stream!()

  @doc """
  Create a new IVF file.
  """
  @spec write!(binary | pid, Ivf.Props.t()) :: Ivf.Writer.t()
  def write!(file, props) when is_pid(file), do: Ivf.Writer.init(file, props)

  def write!(file_path, props) when is_binary(file_path),
    do: File.open!(file_path, [:binary, :write]) |> write!(props)
end
