defmodule Color do
  def new(tile) do
    case tile.id do
      1 -> [243, 216, 138]
      2 -> [144, 184, 221]
      3 -> [193, 181, 208]
      4 -> [188, 208, 151]
      _ -> [0xCA, 0xCA, 0xCA]
    end
  end

  def new(tile, pattern) do
    [
      127 + Integer.mod(tile.i + Color.new(pattern, 0xAA, tile.x, tile.y), 127),
      127 + Integer.mod(tile.i + Color.new(pattern, 0xAA, tile.x, tile.y), 127),
      127 + Integer.mod(tile.i + Color.new(pattern, 0x99, tile.x, tile.y), 127)
    ]
  end

  def new(pattern, color, x, y) do
    color + div(x, pattern.width) * 10 + div(y, pattern.height) * 10
  end
end
