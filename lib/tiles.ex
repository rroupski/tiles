defmodule Tiles do
  @moduledoc """
  Utilities for axis-aligned tiles (rectangles).
  """

  # default maximum gap (in pixels) we’ll treat as adjacency
  @tolerance 10

  @s203 203
  @s406 406
  @s610 610

  @doc """
  Creates a new pattern using a spacer.
  """
  def new(spacer \\ 3) do
    pattern(spacer) |> wrap()
  end

  @doc """
  Arranges tiles of various dimensions in a predetermined, repeating pattern
  across a given rectangular room. This version cycles through images if
  there are not enough to fill all pattern cells.

  A pattern is defined by a "tile" — a repeating unit in the room, and a set of
  "cells" within the tile. Each cell is specified with relative offsets inside the tile
  where an image is placed.
  """
  def pattern(spacer) do
    dx = div(spacer, 2)
    dy = div(spacer, 2)

    [
      new406x406(0, 1, 0),
      new203x406(1, 0 * @s203 + 0, 2 * @s203 + 1 * spacer + dy),
      new203x203(2, 1 * @s203 + 1 * spacer, 2 * @s203 + 1 * spacer + dy),
      new406x406(3, 1 * @s203 + 1 * spacer, 3 * @s203 + 2 * spacer + dy),
      new203x203(4, 1 * @s203 + 1 * spacer, 5 * @s203 + 3 * spacer + dy),
      new406x406(5, 2 * @s203 + 2 * spacer, 1 * @s203 + 1 * spacer),
      new610x406(6, 2 * @s203 + 2 * spacer, 5 * @s203 + 4 * spacer),
      new203x203(7, 3 * @s203 + 2 * spacer + dx, 3 * @s203 + 2 * spacer),
      new406x203(8, 3 * @s203 + 2 * spacer + dx, 4 * @s203 + 3 * spacer),
      new406x610(9, 4 * @s203 + 3 * spacer + dx, 1 * @s203 + spacer),
      new203x203(10, 5 * @s203 + 3 * spacer + dx, 0),
      new406x406(11, 5 * @s203 + 4 * spacer, 4 * @s203 + 3 * spacer)
    ]
  end

  @doc """
  Given a list of Tile.t() (with :x, :y, :width, :height),
  returns a map of index -> list of indices of adjacent tiles.

  Two tiles A and B are adjacent if on one axis their edges are
  within @tolerance pixels (or exactly touching) **and** on the
  other axis they overlap.
  """
  @spec find_adjacent([Tile.t()], non_neg_integer()) :: [{integer(), [integer()]}]
  def find_adjacent(tiles, tolerance \\ @tolerance) when is_list(tiles) do
    tiles_with_idx = Enum.with_index(tiles)

    Enum.map(tiles_with_idx, fn {img, i} ->
      neighbors =
        Enum.filter(tiles_with_idx, fn {other, j} ->
          i != j and adjacent?(img, other, tolerance)
        end)
        |> Enum.map(fn {_other, j} -> j end)

      {i, neighbors}
    end)
  end

  @doc """
  Given:
    1) tiles: a list of Tile.t() (with :x, :y, :width, :height)
    2) tolerance: maximum gap (in pixels) we’ll treat as adjacency

  Returns a map of
    index => [[dx, dy], …]
  where `dx` is the horizontal gap (0 if they overlap or touch in X)
  and `dy` is the vertical gap (0 if they overlap or touch in Y), both as integers.
  The distances are in the same order as the neighbor list.
  """
  def distances(tiles, tolerance \\ @tolerance) do
    adjacency = find_adjacent(tiles, tolerance)

    tiles
    |> side_distances(adjacency)
    |> Stream.zip_with(adjacency, fn {i, d}, {_i, a} -> {i, Enum.zip(a, d)} end)
    |> Stream.map(fn {i, d} ->
      {i, Enum.filter(d, fn {id, _} -> id > i end)}
    end)
    |> Stream.filter(fn {_i, d} -> d != [] end)
    |> Enum.into(Map.new())
  end

  def distances_ex(tiles, tolerance \\ @tolerance) do
    adjacency = find_adjacent(tiles, tolerance)

    tiles
    |> side_distance(adjacency)
    |> Stream.zip_with(adjacency, fn d, {i, _a} -> {i, d} end)
    |> Enum.into(Map.new())
  end

  @doc """
  Calculates dimensions of the area covered by a list of tiles (rectangles).
  """
  @spec dimensions([Tile.t()]) :: {non_neg_integer(), non_neg_integer()}
  def dimensions(tiles) when is_list(tiles) do
    Enum.reduce(
      tiles,
      {0, 0},
      fn %Tile{x: x, y: y, width: w, height: h}, {max_width, max_height} ->
        {
          max(x + w, max_width),
          max(y + h, max_height)
        }
      end
    )
  end

  @doc """
  Returns the min width and height found in a list of tiles.
  """
  @spec min([Tile.t()]) :: {non_neg_integer(), non_neg_integer()}
  def min(tiles) when is_list(tiles) do
    Enum.reduce(
      tiles,
      {nil, nil},
      fn %Tile{width: w, height: h}, {min_width, min_height} ->
        {
          min_not_nil(min_width, w),
          min_not_nil(min_height, h)
        }
      end
    )
  end

  @doc """
  Arranges tiles in a repeating pattern over a rectangular area. If there
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

    # Build a list of absolute tile positions within the room.
    tiles =
      for row <- 0..tile_rows,
          col <- 0..tile_cols,
          cell <- pattern.tiles do
        pos_x = col * pattern.width + cell.x
        pos_y = row * pattern.height + cell.y

        %{x: pos_x, y: pos_y}
      end

    Enum.zip(tiles, Stream.cycle(pattern.tiles)) |> placements()
  end

  defp new203x203(i, x, y) do
    Tile.new(1, i, x, y, @s203, @s203)
  end

  defp new406x406(i, x, y) do
    Tile.new(2, i, x, y, @s406, @s406)
  end

  defp new203x406(i, x, y) do
    Tile.new(3, i, x, y, @s203, @s406)
  end

  defp new406x203(i, x, y) do
    Tile.new(3, i, x, y, @s406, @s203)
  end

  defp new406x610(i, x, y) do
    Tile.new(4, i, x, y, @s406, @s610)
  end

  defp new610x406(i, x, y) do
    Tile.new(4, i, x, y, @s610, @s406)
  end

  defp wrap(tiles) do
    {width, height} = Tiles.dimensions(tiles)
    {min_width, min_height} = Tiles.min(tiles)

    %{
      width: width - min_width + 1,
      height: height - min_height + 1,
      tiles: tiles
    }
  end

  defp placements(col) do
    col
    |> Enum.map(fn {coor, tile} ->
      if coor.x == 1 do
        {%{x: coor.x + 2, y: coor.y}, tile}
      else
        {coor, tile}
      end
    end)
    |> Enum.with_index()
    |> Enum.map(fn {{cell, tile}, i} ->
      Tile.new(tile.id, i, cell.x, cell.y, tile.width, tile.height)
    end)
  end

  @doc """
  Returns the bounding box tile enclosing all given tiles.
  """
  @spec bounding_box([Tile.t()]) :: Tile.t() | nil
  def bounding_box([]), do: nil

  def bounding_box(tiles) do
    {left, top, right, bottom} =
      Enum.reduce(
        tiles,
        {nil, nil, nil, nil},
        fn %Tile{x: x, y: y, width: w, height: h}, {l, t, r, b} ->
          {
            min_not_nil(l, x),
            min_not_nil(t, y),
            max_not_nil(r, x + w),
            max_not_nil(b, y + h)
          }
        end
      )

    Tile.new(left, top, right - left, bottom - top)
  end

  def filter(tiles, min \\ 4, max \\ 6) do
    Enum.each(tiles, fn {i, a} ->
      Enum.filter(a, fn {_t, [dx, dy]} ->
        dx > max or dy > max or (dx > 0 and dx < min) or (dy > 0 and dy < min)
      end)
      |> Enum.each(fn {t, [dx, dy]} ->
        IO.puts("#{pad(i)} -> #{pad(t, 3)}: #{dx}, #{dy}")
      end)
    end)
  end

  defp pad(value, n \\ 4) do
    value
    |> Integer.to_string()
    |> String.pad_leading(n)
  end

  defp side_distances(tiles, adjacency) do
    # normalize to a tuple so we can do O(1) lookups by index
    tuples = tiles |> List.to_tuple()

    # build index => list of [dx, dy] pairs
    Stream.map(adjacency, fn {i, neighbors} ->
      a = elem(tuples, i)

      distances =
        for j <- neighbors do
          b = elem(tuples, j)

          dx =
            cond do
              a.x + a.width < b.x -> b.x - (a.x + a.width)
              b.x + b.width < a.x -> a.x - (b.x + b.width)
              true -> 0
            end

          dy =
            cond do
              a.y + a.height < b.y -> b.y - (a.y + a.height)
              b.y + b.height < a.y -> a.y - (b.y + b.height)
              true -> 0
            end

          [dx, dy]
        end

      {i, distances}
    end)
  end

  defp side_distance(tiles, adjacency) do
    # normalize to a tuple so we can do O(1) lookups by index
    tuples = tiles |> List.to_tuple()

    # build index => list of [dx, dy] pairs
    Stream.map(adjacency, fn {i, neighbors} ->
      a = elem(tuples, i)

      for j <- neighbors do
        b = elem(tuples, j)

        cond do
          a.x + a.width < b.x ->
            b.x - (a.x + a.width)

          b.x + b.width < a.x ->
            a.x - (b.x + b.width)

          true ->
            cond do
              a.y + a.height < b.y -> b.y - (a.y + a.height)
              b.y + b.height < a.y -> a.y - (b.y + b.height)
              true -> 0
            end
        end
      end
    end)
  end

  defp min_not_nil(nil, b), do: b
  defp min_not_nil(a, b), do: min(a, b)

  defp max_not_nil(nil, b), do: b
  defp max_not_nil(a, b), do: max(a, b)

  # check if A and B are side-by-side or one-above-the-other within tolerance
  defp adjacent?(a, b, tol) do
    horizontal_adj?(a, b, tol) or vertical_adj?(a, b, tol)
  end

  # “side by side” within tol px and vertical overlap
  defp horizontal_adj?(a, b, tol) do
    case edge_gap(a.x + a.width, b.x, b.x + b.width, a.x) do
      gap when is_integer(gap) and gap <= tol ->
        overlap?(a.y, a.height, b.y, b.height)

      _ ->
        false
    end
  end

  # “stacked” within tol px and horizontal overlap
  defp vertical_adj?(a, b, tol) do
    case edge_gap(a.y + a.height, b.y, b.y + b.height, a.y) do
      gap when is_integer(gap) and gap <= tol ->
        overlap?(a.x, a.width, b.x, b.width)

      _ ->
        false
    end
  end

  # given a_end, b_start, b_end, a_start, return the positive gap between them
  # or nil if they overlap along that axis
  defp edge_gap(a_end, b_start, b_end, a_start) do
    cond do
      a_end <= b_start -> b_start - a_end
      b_end <= a_start -> a_start - b_end
      true -> nil
    end
  end

  # true if the intervals [p1, p1+len1) and [p2, p2+len2) overlap
  defp overlap?(p1, len1, p2, len2) do
    max(p1, p2) < min(p1 + len1, p2 + len2)
  end
end
