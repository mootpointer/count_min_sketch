defmodule CountMinSketchTest do
  use ExUnit.Case
  doctest CountMinSketch


  test "adding an item increments its count" do
    {_count, sketch} = CountMinSketch.new(30, 128)
    |> CountMinSketch.insert("hello")

    assert CountMinSketch.query(sketch, "hello") == 1
  end

  test "counts are separate" do
    {_count, sketch} = CountMinSketch.new(30, 128)
    |> CountMinSketch.insert("hello", 8)
    |> elem(1)
    |> CountMinSketch.insert("world", 2)

    assert CountMinSketch.query(sketch, "hello") == 8
    assert CountMinSketch.query(sketch, "world") == 2
  end

  test "a big counter is still relatively accurate" do
    sketch = 1..1000
    |> Enum.reduce({0, CountMinSketch.new(1280, 3)}, fn(_, {_, sketch}) ->
      CountMinSketch.insert(sketch, [Faker.Address.latitude, Faker.Address.longitude], :rand.uniform(100) + 50)
    end)
    |> elem(1)
    |> CountMinSketch.insert(["37.563936", "-116.85123"], 122)
    |> elem(1)

    assert CountMinSketch.query(sketch, ["37.563936", "-116.85123"]) == 122
  end
end
