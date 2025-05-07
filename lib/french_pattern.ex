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
    %{
      width: 1437,
      height: 1437,
      tiles: [
        %Tile{width: 406, height: 406, x: 2, y: 0},
        %Tile{width: 203, height: 406, x: 0, y: 410},
        %Tile{width: 203, height: 203, x: 207, y: 410},
        %Tile{width: 406, height: 406, x: 207, y: 619},
        %Tile{width: 203, height: 203, x: 207, y: 1029},
        %Tile{width: 406, height: 406, x: 414, y: 207},
        %Tile{width: 610, height: 406, x: 416, y: 1031},
        %Tile{width: 203, height: 203, x: 619, y: 617},
        %Tile{width: 406, height: 203, x: 619, y: 824},
        %Tile{width: 406, height: 610, x: 826, y: 209},
        %Tile{width: 203, height: 203, x: 1031, y: 2},
        %Tile{width: 406, height: 406, x: 1031, y: 825}
      ]
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
         :width, :height, and :tiles (a list of Tile with :width, :height, :x, and :y).

  ## Returns:
    - placements where:
         - placements: A list of Tiles. Each map contains:
             :x, :y, :width, and :height that describe the tile and its position.
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
      %Tile {
        x: cell.x,
        y: cell.y,
        width: tile.width,
        height: tile.height
      }
    end)
  end
end
