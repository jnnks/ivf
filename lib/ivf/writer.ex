defmodule Ivf.Writer do
  defstruct [:file, :props, frame_count: 0]

  @type writer() :: %Ivf.Writer{}
  @type packet() :: [byte(), ...] | binary()
  @type packet_with_timestamp() :: {non_neg_integer(), packet()}

  @doc """
  Initialize a new Ivf Writer.
  """
  @spec init(pid(), %Ivf.Props{}) :: %Ivf.Writer{}
  def init(file, props = %Ivf.Props{}), do: %__MODULE__{file: file, props: props}

  @doc """
  Append a single frame to the file.
  """
  @spec append(writer(), packet() | packet_with_timestamp()) :: %Ivf.Writer{}
  def append(writer = %Ivf.Writer{file: file}, {timestamp, packet}) do
    if writer.frame_count == 0 do
      :ok = IO.binwrite(file, encode_header(writer.props))
    end

    :ok = IO.binwrite(file, <<byte_size(packet)::32-little>>)
    :ok = IO.binwrite(file, <<timestamp::64-little>>)
    :ok = IO.binwrite(file, packet)

    %Ivf.Writer{writer | frame_count: writer.frame_count + 1}
  end

  def append(writer = %Ivf.Writer{frame_count: fc}, packet), do: append(writer, {fc, packet})

  @doc """
  Append multiple frames to the file.
  """
  @spec append_all(writer(), [packet() | packet_with_timestamp(), ...]) :: writer()
  def append_all(writer = %Ivf.Writer{}, packets) do
    Enum.reduce(packets, writer, fn packet, writer -> append(writer, packet) end)
  end

  @doc """
  Close the file and adjust the frame count in the file header.
  """
  @spec close(writer()) :: :ok | {:error, atom}
  def close(_writer = %Ivf.Writer{file: file, frame_count: fc}) do
    with :ok <- :file.pwrite(file, {:bof, 24}, <<fc::32-little>>),
         :ok <- File.close(file) do
      :ok
    else
      error -> error
    end
  end

  defp encode_header(props = %Ivf.Props{}) do
    {tb_num, tb_den} = props.time_base

    # see: https://wiki.multimedia.cx/index.php/Duck_IVF

    [
      # bytes 0-3    signature: 'DKIF'
      "DKIF",
      # bytes 4-5    version (should be 0)
      <<0, 0>>,
      # bytes 6-7    length of header in bytes
      <<32, 0>>,
      # bytes 8-11   codec FourCC (e.g., 'VP80')
      props.codec,
      # bytes 12-13  width in pixels
      <<props.width::16-little>>,
      # bytes 14-15  height in pixels
      <<props.height::16-little>>,
      # bytes 16-19  time base denominator
      <<tb_den::32-little>>,
      # bytes 20-23  time base numerator
      <<tb_num::32-little>>,
      # bytes 24-27  number of frames in file
      <<props.frame_count::32-little>>,
      # bytes 28-31  unused
      <<0::32>>
    ]
    |> Enum.join()
  end
end
