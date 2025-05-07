defmodule Tiles do
  @moduledoc """
  Utilities for axis-aligned tiles (rectangles).
  """

  @doc """
  Computes the shortest (Euclidean) distance between the edges of two
  non-overlapping tiles (rectangles). Returns 0 if they touch or overlap.
  """
  @spec edge_distance(Tile.t(), Tile.t()) :: {float(), Tile.t(), Tile.t()}
  def edge_distance(
        %Tile{x: x1, y: y1, width: w1, height: h1} = r1,
        %Tile{x: x2, y: y2, width: w2, height: h2} = r2
      ) do
    dx = max(0, max(x2 - (x1 + w1), x1 - (x2 + w2)))
    dy = max(0, max(y1 - (y2 + h2), y2 - (y1 + h1)))
    {:math.sqrt(dx * dx + dy * dy), r1, r2}
  end

  @doc """
  Calculates dimensions of the area covered by the given list of tiles (rectangles).
  """
  @spec dimensions([Tile.t()]) :: {number(), number()}
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
  Given a list of tiles (rectangles), returns a list of distances between
  each unique pair of tiles in that list.
  """
  @spec distances([Tile.t()]) :: [float()]
  def distances(tiles) when is_list(tiles) do
    tiles
    |> Enum.with_index()
    |> Enum.flat_map(fn {r1, i} ->
      Enum.drop(tiles, i + 1)
      |> Enum.map(fn r2 -> edge_distance(r1, r2) end)
    end)
    |> Enum.filter(fn {dist, _, _} -> dist > 0.0 and dist < 40.0 end)
    |> Enum.map(&elem(&1, 0))
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

  defp min_not_nil(nil, b), do: b
  defp min_not_nil(a, b), do: min(a, b)

  defp max_not_nil(nil, b), do: b
  defp max_not_nil(a, b), do: max(a, b)
end
