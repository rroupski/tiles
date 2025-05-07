defmodule TilesTest do
  use ExUnit.Case

  alias Tile
  alias Tiles

  describe "Tiles.edge_distance/2" do
    test "returns 0 for overlapping tiles" do
      a = Tile.new(0, 0, 5, 5)
      b = Tile.new(2, 2, 5, 5)
      assert {+0.0, ^a, ^b} = Tiles.edge_distance(a, b)
    end

    test "computes correct distance for separate tiles" do
      a = Tile.new(0, 0, 2, 2)
      b = Tile.new(5, 5, 2, 2)
      {dist, ^a, ^b} = Tiles.edge_distance(a, b)
      assert Float.round(dist, 2) == 4.24
    end

    test "returns 0 when tiles touch at edge" do
      a = Tile.new(0, 0, 2, 2)
      b = Tile.new(2, 0, 2, 2)
      assert {+0.0, ^a, ^b} = Tiles.edge_distance(a, b)
    end
  end

  describe "Tiles.dimensions/1" do
    test "returns max extents from list of tiles" do
      tiles = [Tile.new(0, 0, 2, 3), Tile.new(5, 1, 2, 2)]
      assert Tiles.dimensions(tiles) == {7, 3}
    end

    test "returns {0,0} for empty list" do
      assert Tiles.dimensions([]) == {0, 0}
    end
  end

  describe "Tiles.distances/1" do
    test "filters correct distances between tiles" do
      a = Tile.new(0, 0, 2, 2)
      b = Tile.new(5, 5, 2, 2)
      c = Tile.new(20, 20, 2, 2)
      result = Tiles.distances([a, b, c])
      assert length(result) == 3
      assert Float.round(hd(result), 2) == 4.24
    end
  end

  describe "Tiles.bounding_box/1" do
    test "returns nil for empty list" do
      assert Tiles.bounding_box([]) == nil
    end

    test "computes correct bounding box for tiles" do
      tiles = [Tile.new(1, 1, 2, 2), Tile.new(4, 5, 3, 3)]
      assert Tiles.bounding_box(tiles) == Tile.new(1, 1, 6, 7)
    end
  end
end
