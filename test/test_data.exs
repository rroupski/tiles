defmodule TestData do

  tiles = FrenchPattern.new()

  {width, height} = Tiles.dimensions(tiles)

  IO.puts("width: #{width}, height: #{height}")

  # all consecutive pairs
  Tiles.distances(tiles)
#  |> Enum.each(fn {dx, dy, r1, r2} ->
#    IO.puts("  #{dx},#{dy}:  #{to_string(r1)}, #{to_string(r2)}")
  |> Enum.each(fn d ->
    IO.puts("#{d}")
  end)
end
