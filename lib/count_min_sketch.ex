defmodule CountMinSketch do
  @moduledoc """
  Documentation for CountMinSketch.
  """

  @doc """
  Hello world.

  """

  defstruct [:width, :depth, :table, :count]

  def new(width, depth) do
    %__MODULE__{width: width, depth: depth, table: %{}, count: 0}
  end

  def insert(%__MODULE__{depth: depth, count: count} = sketch, value, amount \\ 1) do
    0..depth
    |> Enum.reduce({count, sketch}, fn(row, {min, sketch}) ->
      {old_count, new_sketch} = update(sketch, row, value, amount)
      {Enum.min([old_count + amount, min]), %__MODULE__{new_sketch | count: count + amount}}
    end)
  end

  def query(sketch, value) do
    elem(insert(sketch, value, 0), 0)
  end

  defp update(%{width: width} = sketch, row, value, amount) do
    index = index(value, row, width)
    get_and_update_in(sketch, [Access.key(:table, %{}), Access.key(row, %{}), Access.key(index, 0)], &{&1, &1 + amount})
  end

  defp index(value, row, width) do
    value
    |> Murmur.hash_x64_128(row)
    |> rem(width)
  end
end
