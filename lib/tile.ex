defmodule Tile do
  @moduledoc """
  An axis-aligned tile (rectangle) defined by:
    • x, y        — the coordinates of its upper-left corner
    • width       — its extent along the x-axis (must be ≥ 0)
    • height      — its extent along the y-axis (must be ≥ 0)
  """

  defstruct [:id, :i, :x, :y, :width, :height]

  @type t :: %__MODULE__{
          id: non_neg_integer(),
          i: integer(),
          x: integer(),
          y: integer(),
          width: non_neg_integer(),
          height: non_neg_integer()
        }

  @doc """
  Creates a new tile at the given x and y.
  """
  @spec new(integer(), integer(), non_neg_integer(), non_neg_integer()) :: t()
  def new(x, y, width, height) do
    new(-1, x, y, width, height)
  end

  @doc """
  Creates a new tile at the given x and y.
  """
  @spec new(integer(), integer(), integer(), non_neg_integer(), non_neg_integer()) :: t()
  def new(i, x, y, width, height) do
    new(0, i, x, y, width, height)
  end

  @doc """
  Creates a new tile, enforcing non-negative width and height.
  """
  @spec new(
          non_neg_integer(),
          integer(),
          integer(),
          integer(),
          non_neg_integer(),
          non_neg_integer()
        ) :: t()
  def new(id, i, x, y, width, height) when width >= 0 and height >= 0 do
    %__MODULE__{id: id, i: i, x: x, y: y, width: width, height: height}
  end

  def new(_, _, _, _, width, height) do
    raise ArgumentError,
          "width and height must be non-negative, got width=#{width}, height=#{height}"
  end

  @doc """
  Checks if two tiles overlap (intersect in area).
  """
  @spec overlaps?(t(), t()) :: boolean()
  def overlaps?(%__MODULE__{} = a, %__MODULE__{} = b) do
    a.x < b.x + b.width and
      b.x < a.x + a.width and
      a.y < b.y + b.height and
      b.y < a.y + a.height
  end

  defimpl String.Chars, for: Tile do
    def to_string(%Tile{id: id, i: i, x: x, y: y, width: width, height: height}) do
      "[#{pad(i, 4)} | #{id}: [#{pad(x, 4)}, #{pad(y, 4)}] #{width}x#{height}]"
    end

    defp pad(value, n) do
      value
      |> Integer.to_string()
      |> String.pad_leading(n)
    end
  end
end
