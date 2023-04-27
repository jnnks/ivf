defmodule IvfTest do
  use ExUnit.Case
  doctest Ivf

  @tag :stream
  test "Stream VP8 File" do
    {props = %Ivf.Props{}, stream} = Ivf.stream!("test/videos/test_vp8.ivf")
    assert props.codec == "VP80"

    frames = Enum.to_list(stream)
    assert props.frame_count == length(frames)
  end

  @tag :stream
  test "Stream AV1 File" do
    {props = %Ivf.Props{}, stream} = Ivf.stream!("test/videos/test_av1.ivf")
    assert props.codec == "AV01"

    frames = Enum.to_list(stream)
    assert props.frame_count == length(frames)
  end

  @tag :props
  test "Props with Keyword" do
    assert match?(%Ivf.Props{width: 100, height: 99}, Ivf.Props.new(width: 100, height: 99))
    assert match?(%Ivf.Props{time_base: {6, 9}}, Ivf.Props.new(time_base: {6, 9}))
    assert match?(%Ivf.Props{codec: "AV01"}, Ivf.Props.new(codec: "AV01"))
  end

  @tag :write22
  test "Copy VP8 File" do
    {props = %Ivf.Props{}, stream} = Ivf.stream!("test/videos/test_vp8.ivf")
    frames = Enum.to_list(stream)

    original = File.read!("test/videos/test_vp8.ivf")

    writer = Ivf.write!("test/videos/out.ivf", props)
    Ivf.Writer.append_all(writer, frames)
    copy = File.read!("test/videos/out.ivf")

    assert original == copy, "copy does not match original"
  end

  @tag :write
  test "Copy AV1 File" do
    {props = %Ivf.Props{}, stream} = Ivf.stream!("test/videos/test_av1.ivf")
    frames = Enum.to_list(stream)

    original = File.read!("test/videos/test_av1.ivf")

    writer = Ivf.write!("test/videos/out.ivf", props)
    Ivf.Writer.append_all(writer, frames)
    copy = File.read!("test/videos/out.ivf")

    assert original == copy, "copy does not match original"
  end

  @tag :write
  test "Write No Frames and Append" do
    file = File.open!("test/videos/out.ivf", [:binary, :write])
    writer = Ivf.write!(file, Ivf.Props.new([]))
    {:ok, %File.Stat{size: file_size}} = File.stat("test/videos/out.ivf")
    assert file_size == 0

    writer = Ivf.Writer.append(writer, "invalid_test_frame")

    {props, stream} = Ivf.stream!("test/videos/out.ivf")
    frames = Enum.to_list(stream)
    assert props == Ivf.Props.new([])
    assert frames == [{0, "invalid_test_frame"}]

    :ok = Ivf.Writer.close(writer)
    {props, _stream} = Ivf.stream!("test/videos/out.ivf")
    assert props.frame_count == 1
  end
end
