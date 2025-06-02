defmodule Tile do
  @moduledoc """
  An axis-aligned tile (rectangle) defined by:
    • x, y        — the coordinates of its upper-left corner
    • width       — its extent along the x-axis (must be ≥ 0)
    • height      — its extent along the y-axis (must be ≥ 0)
  """

  defstruct [:x, :y, :width, :height]

  @type t :: %__MODULE__{
          x: integer(),
          y: integer(),
          width: non_neg_integer(),
          height: non_neg_integer()
        }

  @doc """
  Creates a new tile, enforcing non-negative width and height.
  """
  @spec new(number(), number(), non_neg_integer(), non_neg_integer()) :: t()
  def new(x, y, width, height) when width >= 0 and height >= 0 do
    %__MODULE__{x: x, y: y, width: width, height: height}
  end

  def new(_, _, width, height) do
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
    def to_string(%Tile{x: x, y: y, width: width, height: height}) do
      "[x: #{pad(x, 4)}, y: #{pad(y, 4)}, #{width}x#{height}]"
    end

    defp pad(value, n) when is_integer(value) do
      value
      |> Integer.to_string()
      |> String.pad_leading(n)
    end

    defp pad(value, n) when is_float(value) do
      value
      |> format_float()
      |> String.pad_leading(n)
    end

    defp pad(value, _n) do
      raise ArgumentError, "pad/2 expects a number, got: #{inspect(value)}"
    end

    defp format_float(value) when value == trunc(value), do: Integer.to_string(trunc(value))
    defp format_float(value), do: :erlang.float_to_binary(value, decimals: 2)
  end
end
