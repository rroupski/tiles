defmodule FrenchPattern do
  @moduledoc """
  Arranges tiles of various dimensions in a predetermined, repeating pattern
  across a given rectangular room. This version cycles through images if
  there are not enough to fill all pattern cells.

  A pattern is defined by a "tile" — a repeating unit in the room, and a set of
  "cells" within the tile. Each cell is specified with relative offsets inside the tile
  where an image is placed.
  """

  @s203 203
  @s406 406
  @s610 610

  @doc """
  Creates a new pattern using a spacer.
  """
  def new(spacer \\ 3) do
    pattern(spacer) |> wrap()
  end

  def pattern(spacer) do
    dx = div(spacer, 2)
    dy = div(spacer, 2)

    [
      Tile.new(0, dx, 0, @s406, @s406),
      Tile.new(1, 0 * @s203 + 0 * spacer, 2 * @s203 + 1 * spacer + dy, @s203, @s406),
      Tile.new(2, 1 * @s203 + 1 * spacer, 2 * @s203 + 1 * spacer, @s203, @s203),
      Tile.new(3, 1 * @s203 + 1 * spacer, 3 * @s203 + 2 * spacer + dy, @s406, @s406),
      Tile.new(4, 1 * @s203 + 1 * spacer, 5 * @s203 + 3 * spacer + dy, @s203, @s203),
      Tile.new(5, 2 * @s203 + 2 * spacer, 1 * @s203 + 1 * spacer, @s406, @s406),
      Tile.new(6, 2 * @s203 + 2 * spacer + dx - 1, 5 * @s203 + 4 * spacer, @s610, @s406),
      Tile.new(7, 3 * @s203 + 2 * spacer + dx, 3 * @s203 + 2 * spacer, @s203, @s203),
      Tile.new(8, 3 * @s203 + 2 * spacer + dx, 4 * @s203 + 3 * spacer, @s406, @s203),
      Tile.new(9, 4 * @s203 + 3 * spacer + dx, 1 * @s203 + spacer + dy - 1, @s406, @s610),
      Tile.new(10, 5 * @s203 + 4 * spacer, 0, @s203, @s203),
      Tile.new(11, 5 * @s203 + 4 * spacer, 4 * @s203 + 3 * spacer, @s406, @s406)
    ]
  end

  defp wrap(tiles) do
    {width, height} = Tiles.dimensions(tiles)
    {min_width, min_height} = Tiles.min(tiles)

    %{
      width: width - min_width + 2,
      height: height - min_height + 2,
      tiles: tiles
    }
  end
end
