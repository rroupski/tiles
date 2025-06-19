defmodule Color do
  def new(pattern, x, y) do
    new(pattern, 0xAA, x, y)
  end

  def new(pattern, color, x, y) do
    color + div(x, pattern.width) * 10 + div(y, pattern.height) * 10
  end
end
