defmodule Tiles do
  @moduledoc """
  Utilities for axis-aligned tiles (rectangles).
  """

  # default maximum gap (in pixels) we’ll treat as adjacency
  @tolerance 10

  @doc """
  Given a list of Tile.t() (with :x, :y, :width, :height),
  returns a map of index -> list of indices of adjacent tiles.

  Two tiles A and B are adjacent if on one axis their edges are
  within @tolerance pixels (or exactly touching) **and** on the
  other axis they overlap.
  """
  @spec find_adjacent([Tile.t()], non_neg_integer()) :: %{integer() => [integer()]}
  def find_adjacent(tiles, tolerance \\ @tolerance) when is_list(tiles) when is_list(tiles) do
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
    |> Stream.filter(fn {_i, d} -> d != [] end)
    |> Enum.into([])
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
      fn %Tile{x: _, y: _, width: w, height: h}, {min_width, min_height} ->
        {
          min_not_nil(min_width, w),
          min_not_nil(min_height, h)
        }
      end
    )
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
