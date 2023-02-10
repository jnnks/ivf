defmodule IvfTest do
  use ExUnit.Case
  doctest Ivf

  test "stream VP8 file" do
    {props = %Ivf.Props{}, stream} = Ivf.stream!("test/videos/test_vp8.ivf")
    assert props.codec == "VP80"

    frames = Enum.to_list(stream)
    assert props.frame_count == length(frames)
  end

  test "stream AV1 file" do
    {props = %Ivf.Props{}, stream} = Ivf.stream!("test/videos/test_av1.ivf")
    assert props.codec == "AV01"

    frames = Enum.to_list(stream)
    assert props.frame_count == length(frames)
  end

  test "copy VP9 file" do
    {props = %Ivf.Props{}, stream} = Ivf.stream!("test/videos/test_vp8.ivf")
    frames = Enum.to_list(stream)

    Ivf.write!("test/videos/out.ivf", props) |> Ivf.append_all(frames)

    original = File.read!("test/videos/test_vp8.ivf")
    copy = File.read!("test/videos/out.ivf")
    assert original == copy
  end

  test "copy AV1 file" do
    {props = %Ivf.Props{}, stream} = Ivf.stream!("test/videos/test_av1.ivf")
    frames = Enum.to_list(stream)

    Ivf.write!("test/videos/out.ivf", props) |> Ivf.append_all(frames, true)

    original = File.read!("test/videos/test_av1.ivf")
    copy = File.read!("test/videos/out.ivf")
    assert original == copy, "copy does not match original"
  end
end
