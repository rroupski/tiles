defmodule Color do
  def new(tile) do
    div(tile.i, 12) |> new_color()
  end

  defp new_color(id) do
    case Integer.mod(id, 6) do
      0 -> [0xCA, 0xCA, 0xCA]
      1 -> [243, 216, 138]
      2 -> [144, 184, 221]
      3 -> [193, 181, 208]
      4 -> [88, 208, 151]
      5 -> [0x9B, 0x9B, 0x7A]
    end
  end
end
