
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

    test "returns true when one tile is completely inside another" do
      a = Tile.new(0, 0, 10, 10)
      b = Tile.new(2, 2, 3, 3)
      assert Tile.overlaps?(a, b)
      assert Tile.overlaps?(b, a)
    end

    test "returns true for partial overlap (corner)" do
      a = Tile.new(0, 0, 5, 5)
      b = Tile.new(4, 4, 5, 5)
      assert Tile.overlaps?(a, b)
    end

    test "returns false when tiles are apart (left)" do
      a = Tile.new(10, 0, 5, 5)
      b = Tile.new(0, 0, 5, 5)
      refute Tile.overlaps?(a, b)
    end

    test "returns false when tiles are apart (above)" do
      a = Tile.new(0, 10, 5, 5)
      b = Tile.new(0, 0, 5, 5)
      refute Tile.overlaps?(a, b)
    end

    test "returns true for identical tiles" do
      a = Tile.new(5, 5, 10, 10)
      b = Tile.new(5, 5, 10, 10)
      assert Tile.overlaps?(a, b)
    end
  end

  describe "Tile.new/5" do
    test "creates tile with index" do
      tile = Tile.new(5, 10, 20, 100, 200)
      assert tile.i == 5
      assert tile.x == 10
      assert tile.y == 20
      assert tile.width == 100
      assert tile.height == 200
    end

    test "sets default id to 0" do
      tile = Tile.new(5, 10, 20, 100, 200)
      assert tile.id == 0
    end
  end

  describe "Tile.new/6" do
    test "creates tile with id and index" do
      tile = Tile.new(3, 7, 10, 20, 100, 200)
      assert tile.id == 3
      assert tile.i == 7
      assert tile.x == 10
      assert tile.y == 20
      assert tile.width == 100
      assert tile.height == 200
    end

    test "allows zero dimensions" do
      tile = Tile.new(0, 0, 0, 0, 0, 0)
      assert tile.width == 0
      assert tile.height == 0
    end

    test "raises for negative width in 6-arg constructor" do
      assert_raise ArgumentError, ~r/width and height must be non-negative/, fn ->
        Tile.new(1, 2, 0, 0, -5, 10)
      end
    end

    test "raises for negative height in 6-arg constructor" do
      assert_raise ArgumentError, ~r/width and height must be non-negative/, fn ->
        Tile.new(1, 2, 0, 0, 10, -5)
      end
    end
  end
end
