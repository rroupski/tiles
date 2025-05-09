defmodule FrenchPattern do
  @moduledoc """
  Arranges tiles of various dimensions in a predetermined, repeating pattern
  across a given rectangular room. This version cycles through images if
  there are not enough to fill all pattern cells.

  A pattern is defined by a "tile" — a repeating unit in the room, and a set of
  "cells" within the tile. Each cell is specified with relative offsets inside the tile
  where an image is placed.
  """
  def new() do
    tiles = [
      Tile.new(2, 0, 406, 406),
      Tile.new(0, 410, 203, 406),
      Tile.new(207, 410, 203, 203),
      Tile.new(207, 619, 406, 406),
      Tile.new(207, 1029, 203, 203),
      Tile.new(414, 207, 406, 406),
      Tile.new(416, 1031, 610, 406),
      Tile.new(619, 617, 203, 203),
      Tile.new(619, 824, 406, 203),
      Tile.new(826, 209, 406, 610),
      Tile.new(1031, 2, 203, 203),
      Tile.new(1031, 825, 406, 406)
    ]

    {width, height} = Tiles.dimensions(tiles)
    {min_width, min_height} = Tiles.min(tiles)

    %{
      width: width - min_width,
      height: height - min_height,
      tiles: tiles
    }
  end

  @doc """
  Arranges tiles in a repeating pattern over a rectangular room. If there
  are not enough tiles to fill all available pattern cells, the algorithm cycles
  back to the first image to ensure that every cell is populated.

  ## Parameters:
    - width: The width of the room.
    - height: The height of the room.
    - pattern: A map defining the repeating pattern. It must include:
         :width, :height, and :tiles (a list of %{Tile} with :width, :height, :x, and :y).

  ## Returns:
    - placements where:
         - placements: A list of %{Tile}
  """
  def arrange(width, height, pattern) do
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
