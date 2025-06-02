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
  Creates a new pattern using 4 mm spacer.
  """
  def new4() do
    new_x(4) |> new()
  end

  @doc """
  Creates a new pattern using 5 mm spacer.
  """
  def new5() do
    new_x(5) |> new()
  end

  @doc """
  Creates a new pattern using 6 mm spacer.
  """
  def new6() do
    new_x(6) |> new()
  end

  @doc """
  Creates a new pattern using 8 mm spacer.
  """
  def new8() do
    new_x(8) |> new()
  end

  def new_x(spacer \\ 4) do
    dx = div(spacer, 2)
    dy = div(spacer, 2)

    [
      Tile.new(dx, 0, @s406, @s406),
      Tile.new(0 * @s203 + 0 * spacer, 2 * @s203 + 1 * spacer + dy, @s203, @s406),
      Tile.new(1 * @s203 + 1 * spacer, 2 * @s203 + 1 * spacer, @s203, @s203),
      Tile.new(1 * @s203 + 1 * spacer, 3 * @s203 + 2 * spacer + dy, @s406, @s406),
      Tile.new(1 * @s203 + 1 * spacer, 5 * @s203 + 3 * spacer + dy, @s203, @s203),
      Tile.new(2 * @s203 + 2 * spacer, 1 * @s203 + 1 * spacer, @s406, @s406),
      Tile.new(2 * @s203 + 2 * spacer + dx, 5 * @s203 + 4 * spacer, @s610, @s406),
      Tile.new(3 * @s203 + 2 * spacer + dx, 3 * @s203 + 2 * spacer, @s203, @s203),
      Tile.new(3 * @s203 + 2 * spacer + dx, 4 * @s203 + 3 * spacer, @s406, @s203),
      Tile.new(4 * @s203 + 3 * spacer + dx, 1 * @s203 + spacer + dy, @s406, @s610),
      Tile.new(5 * @s203 + 4 * spacer, 0, @s203, @s203),
      Tile.new(5 * @s203 + 4 * spacer, 4 * @s203 + 3 * spacer, @s406, @s406)
    ]
  end

  def new(tiles) do
    {width, height} = Tiles.dimensions(tiles)
    {min_width, min_height} = Tiles.min(tiles)

    %{
      width: width - min_width + 2,
      height: height - min_height + 2,
      tiles: tiles
    }
  end

  @doc """
  Arranges tiles in a repeating pattern over a rectangular room. If there
  are not enough tiles to fill all available pattern cells, the algorithm cycles
  back to the first image to ensure that every cell is populated.

  ## Parameters:
  - pattern: A map defining the repeating pattern. It must include:
       :width, :height, and :tiles (a list of %{Tile} with :width, :height, :x, and :y).
    - width: The width of the room.
    - height: The height of the room.

  ## Returns:
    - placements where:
         - placements: A list of %{Tile}
  """
  def arrange(pattern, width, height) do
    # Determine how many patterns (based on the pattern dimensions) can fit
    tile_cols = div(width, pattern.width)
    tile_rows = div(height, pattern.height)

    IO.puts("Cols: #{tile_cols}, rows: #{tile_rows}")

    # Build a list of absolute tile positions within the room.
    available_tiles =
      for row <- 0..tile_rows,
          col <- 0..tile_cols,
          cell <- pattern.tiles do
        pos_x = col * pattern.width + cell.x
        pos_y = row * pattern.height + cell.y

        %{x: pos_x, y: pos_y}
      end

    IO.puts(
      "Distinct tiles: #{length(pattern.tiles)}, available tiles: #{length(available_tiles)}."
    )

    if length(pattern.tiles) < length(available_tiles) do
      # Not enough distinct tiles: cycle through the images to fill every cell.
      Enum.zip(available_tiles, Stream.cycle(pattern.tiles))
      |> placements()
    else
      # There are enough tiles: assign each cell one image in order
      Enum.zip(available_tiles, pattern.tiles)
      |> placements()
    end
  end

  defp placements(col) do
    Enum.map(col, fn {cell, tile} ->
      %Tile{
        x: cell.x,
        y: cell.y,
        width: tile.width,
        height: tile.height
      }
    end)
  end
end
