
defmodule TileTest do
  use ExUnit.Case
  alias Tile

  describe "Tile.new/4" do
    test "creates tile with valid dimensions" do
      assert %Tile{x: 1, y: 2, width: 10, height: 5} = Tile.new(1, 2, 10, 5)
    end

    test "raises for negative width" do
      assert_raise ArgumentError, ~r/width and height must be non-negative/, fn ->
        Tile.new(0, 0, -1, 5)
      end
    end

    test "raises for negative height" do
      assert_raise ArgumentError, ~r/width and height must be non-negative/, fn ->
        Tile.new(0, 0, 5, -1)
      end
    end
  end

  describe "Tile string representation" do
    test "formats integer tile" do
      tile = Tile.new(1, 2, 10, 5)
      assert to_string(tile) == "[  -1 | 0: [   1,    2] 10x5]"
    end

    test "formats float tile" do
      tile = Tile.new(1.0, 2.25, 10, 5)
      assert to_string(tile) == "[  -1 | 0: [1.00, 2.25] 10x5]"
    end

    test "formats padded output consistently" do
      tile = Tile.new(99, 5.5, 10, 5)
      assert to_string(tile) == "[  -1 | 0: [  99, 5.50] 10x5]"
    end
  end

  describe "Tile.overlaps?/2" do
    test "returns true for overlapping tiles" do
      a = Tile.new(0, 0, 5, 5)
      b = Tile.new(3, 3, 5, 5)
      assert Tile.overlaps?(a, b)
    end

    test "returns false when tiles do not overlap (right)" do
      a = Tile.new(0, 0, 5, 5)
      b = Tile.new(6, 0, 5, 5)
      refute Tile.overlaps?(a, b)
    end

    test "returns false when tiles do not overlap (below)" do
      a = Tile.new(0, 0, 5, 5)
      b = Tile.new(0, 6, 5, 5)
      refute Tile.overlaps?(a, b)
    end

    test "returns false for edge-touching tiles (no area overlap)" do
      a = Tile.new(0, 0, 5, 5)
      b = Tile.new(5, 0, 5, 5)
      refute Tile.overlaps?(a, b)
    end
  end
end
