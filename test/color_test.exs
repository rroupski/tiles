defmodule ColorTest do
  use ExUnit.Case

  alias Color
  alias Tile

  describe "Color.new/1" do
    test "generates color for tile with index 0" do
      tile = Tile.new(0, 0, 0, 0, 10, 10)
      color = Color.new(tile)
      assert color == [0xDB, 0xDB, 0xDB]
    end

    test "generates color for tile with index 1" do
      tile = Tile.new(0, 1, 0, 0, 10, 10)
      color = Color.new(tile)
      assert color == [0xDB, 0xDB, 0xDB]
    end

    test "generates color for tile with index 12" do
      tile = Tile.new(0, 12, 0, 0, 10, 10)
      color = Color.new(tile)
      assert color == [0xF5, 0xE9, 0x9B]
    end

    test "generates color for tile with index 24" do
      tile = Tile.new(0, 24, 0, 0, 10, 10)
      color = Color.new(tile)
      assert color == [0xA1, 0xC9, 0xEE]
    end

    test "cycles through 6-color palette" do
      colors =
        for i <- 0..71 do
          tile = Tile.new(0, i, 0, 0, 10, 10)
          Color.new(tile)
        end

      unique_colors = Enum.uniq(colors)
      assert length(unique_colors) == 6
    end

    test "returns valid RGB values" do
      tile = Tile.new(0, 5, 0, 0, 10, 10)
      [r, g, b] = Color.new(tile)
      assert r in 0..255
      assert g in 0..255
      assert b in 0..255
    end

    test "generates consistent colors for same index" do
      tile1 = Tile.new(0, 15, 0, 0, 10, 10)
      tile2 = Tile.new(0, 15, 100, 100, 20, 20)
      assert Color.new(tile1) == Color.new(tile2)
    end

    test "different index groups get different colors" do
      tile1 = Tile.new(0, 0, 0, 0, 10, 10)
      tile2 = Tile.new(0, 12, 0, 0, 10, 10)
      refute Color.new(tile1) == Color.new(tile2)
    end
  end
end
