defmodule Color do
  @moduledoc """
  Generates colors for tiles based on tile index using a cycling color palette.
  """

  @doc """
  Create a color for the given tile.
  """
  def new(%{i: i}) when is_integer(i), do: div(i, 12) |> palette_color()

  @palette [
    [0xDB, 0xDB, 0xDB],
    [0xF5, 0xE9, 0x9B],
    [0xA1, 0xC9, 0xEE],
    [0xD2, 0xC6, 0xE1],
    [0x69, 0xE0, 0xA7],
    [0xAB, 0xAB, 0x8A]
  ]

  defp palette_color(id) do
    Enum.at(@palette, rem(id, length(@palette)))
  end
end
