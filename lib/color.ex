defmodule Color do
  @moduledoc """
  Generates colors for tiles based on tile index using a cycling color palette.
  """

  @doc """
  Create a color for the given tile.
  """
  def new(%{i: i}) when is_integer(i), do: div(i, 12) |> palette_color()

  @palette [
    [0xCA, 0xCA, 0xCA],
    [0xF3, 0xD8, 0x8A],
    [0x90, 0xB8, 0xDD],
    [0xC1, 0xB5, 0xD0],
    [0x58, 0xD0, 0x97],
    [0x9B, 0x9B, 0x7A]
  ]

  defp palette_color(id) do
    Enum.at(@palette, rem(id, length(@palette)))
  end
end
