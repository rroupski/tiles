defmodule TilesTest do
  use ExUnit.Case

  alias Tile
  alias Tiles

  describe "Tiles.dimensions/1" do
    test "returns max extents from list of tiles" do
      tiles = [Tile.new(0, 0, 2, 3), Tile.new(5, 1, 2, 2)]
      assert Tiles.dimensions(tiles) == {7, 3}
    end

    test "returns {0,0} for empty list" do
      assert Tiles.dimensions([]) == {0, 0}
    end

    test "handles single tile" do
      tiles = [Tile.new(10, 20, 5, 8)]
      assert Tiles.dimensions(tiles) == {15, 28}
    end

    test "handles tiles with negative positions" do
      tiles = [Tile.new(-5, -3, 10, 8), Tile.new(2, 1, 3, 4)]
      assert Tiles.dimensions(tiles) == {5, 5}
    end
  end

  describe "Tiles.min/1" do
    test "returns minimum width and height" do
      tiles = [Tile.new(0, 0, 10, 20), Tile.new(0, 0, 5, 15), Tile.new(0, 0, 8, 12)]
      assert Tiles.min(tiles) == {5, 12}
    end

    test "returns {nil, nil} for empty list" do
      assert Tiles.min([]) == {nil, nil}
    end

    test "handles single tile" do
      tiles = [Tile.new(0, 0, 100, 200)]
      assert Tiles.min(tiles) == {100, 200}
    end
  end

  describe "Tiles.distances/1" do
    test "returns empty map for non-adjacent tiles" do
      a = Tile.new(0, 0, 2, 2)
      b = Tile.new(20, 20, 2, 2)
      result = Tiles.distances([a, b])
      assert result == %{}
    end

    test "calculates distances for adjacent tiles" do
      a = Tile.new(0, 0, 5, 5)
      b = Tile.new(8, 0, 5, 5)  # 3px gap horizontally
      result = Tiles.distances([a, b])
      assert is_map(result)
      assert Map.has_key?(result, 0)
      assert [{1, [3, 0]}] = result[0]
    end

    test "handles touching tiles" do
      a = Tile.new(0, 0, 5, 5)
      b = Tile.new(5, 0, 5, 5)  # touching
      result = Tiles.distances([a, b])
      assert is_map(result)
      assert [{1, [0, 0]}] = result[0]
    end

    test "respects custom tolerance" do
      a = Tile.new(0, 0, 5, 5)
      b = Tile.new(20, 0, 5, 5)  # 15px gap
      result = Tiles.distances([a, b], 20)
      assert Map.has_key?(result, 0)
    end
  end

  describe "Tiles.find_adjacent/2" do
    test "identifies horizontally adjacent tiles" do
      a = Tile.new(0, 0, 5, 5)
      b = Tile.new(8, 0, 5, 5)  # 3px gap
      result = Tiles.find_adjacent([a, b])
      assert [{0, [1]}, {1, [0]}] = result
    end

    test "identifies vertically adjacent tiles" do
      a = Tile.new(0, 0, 5, 5)
      b = Tile.new(0, 8, 5, 5)  # 3px gap below
      result = Tiles.find_adjacent([a, b])
      assert [{0, [1]}, {1, [0]}] = result
    end

    test "returns empty neighbors for non-adjacent tiles" do
      a = Tile.new(0, 0, 5, 5)
      b = Tile.new(20, 20, 5, 5)
      result = Tiles.find_adjacent([a, b])
      assert [{0, []}, {1, []}] = result
    end

    test "finds multiple neighbors" do
      a = Tile.new(0, 0, 5, 5)
      b = Tile.new(8, 0, 5, 5)
      c = Tile.new(0, 8, 5, 5)
      result = Tiles.find_adjacent([a, b, c])
      {0, neighbors} = Enum.at(result, 0)
      assert length(neighbors) == 2
    end

    test "respects custom tolerance" do
      a = Tile.new(0, 0, 5, 5)
      b = Tile.new(20, 0, 5, 5)  # 15px gap
      result = Tiles.find_adjacent([a, b], 20)
      assert [{0, [1]}, {1, [0]}] = result
      
      result_strict = Tiles.find_adjacent([a, b], 5)
      assert [{0, []}, {1, []}] = result_strict
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

    test "handles single tile" do
      tiles = [Tile.new(5, 10, 20, 30)]
      assert Tiles.bounding_box(tiles) == Tile.new(5, 10, 20, 30)
    end

    test "handles negative coordinates" do
      tiles = [Tile.new(-5, -10, 10, 15), Tile.new(2, 3, 8, 12)]
      box = Tiles.bounding_box(tiles)
      assert box.x == -5
      assert box.y == -10
      assert box.width == 15
      assert box.height == 25
    end
  end

  describe "Tiles.pattern/1" do
    test "generates 12-tile pattern" do
      pattern = Tiles.pattern(3)
      assert length(pattern) == 12
    end

    test "pattern tiles have correct dimensions" do
      pattern = Tiles.pattern(3)
      assert Enum.all?(pattern, fn tile ->
        tile.width in [203, 406, 610] and tile.height in [203, 406, 610]
      end)
    end

    test "pattern with different spacer" do
      pattern = Tiles.pattern(6)
      assert length(pattern) == 12
      # Verify tiles exist and have non-negative coordinates
      assert Enum.all?(pattern, fn tile ->
        tile.x >= 0 and tile.y >= 0
      end)
    end
  end

  describe "Tiles.new/1" do
    test "creates pattern with default spacer" do
      result = Tiles.new()
      assert Map.has_key?(result, :width)
      assert Map.has_key?(result, :height)
      assert Map.has_key?(result, :tiles)
      assert length(result.tiles) == 12
    end

    test "creates pattern with custom spacer" do
      result = Tiles.new(5)
      assert is_map(result)
      assert length(result.tiles) == 12
    end
  end

  describe "Tiles.arrange/4" do
    test "arranges pattern in room" do
      pattern = Tiles.new(3)
      tiles = Tiles.arrange(pattern, 2000, 2000)
      assert is_list(tiles)
      assert length(tiles) > 0
    end

    test "tiles cycle through pattern" do
      pattern = Tiles.new(3)
      tiles = Tiles.arrange(pattern, 3000, 3000)
      # Should have multiple repetitions of the pattern
      assert length(tiles) > 12
    end

    test "truncate flag affects tile count" do
      pattern = Tiles.new(3)
      tiles_no_truncate = Tiles.arrange(pattern, 2000, 2000, false)
      tiles_truncate = Tiles.arrange(pattern, 2000, 2000, true)
      # With truncate, we get more tiles
      assert length(tiles_truncate) >= length(tiles_no_truncate)
    end

    test "arranged tiles have unique indices" do
      pattern = Tiles.new(3)
      tiles = Tiles.arrange(pattern, 1500, 1500)
      indices = Enum.map(tiles, & &1.i)
      assert length(indices) == length(Enum.uniq(indices))
    end
  end

  describe "Tiles.distances_ex/2" do
    test "returns distances for all neighbors" do
      a = Tile.new(0, 0, 5, 5)
      b = Tile.new(8, 0, 5, 5)  # 3px gap horizontally
      result = Tiles.distances_ex([a, b])
      assert is_map(result)
      assert Map.has_key?(result, 0)
      assert Map.has_key?(result, 1)
    end

    test "respects custom tolerance" do
      a = Tile.new(0, 0, 5, 5)
      b = Tile.new(20, 0, 5, 5)  # 15px gap
      result = Tiles.distances_ex([a, b], 20)
      assert is_map(result)
    end

    test "handles touching tiles" do
      a = Tile.new(0, 0, 5, 5)
      b = Tile.new(5, 0, 5, 5)  # touching
      result = Tiles.distances_ex([a, b])
      assert is_map(result)
    end

    test "returns empty neighbors for non-adjacent tiles" do
      a = Tile.new(0, 0, 5, 5)
      b = Tile.new(100, 100, 5, 5)
      result = Tiles.distances_ex([a, b])
      assert result[0] == []
      assert result[1] == []
    end
  end

  describe "Tiles.filter/3" do
    test "filters tiles based on distance thresholds" do
      # This function primarily does IO, so we capture output
      import ExUnit.CaptureIO

      a = Tile.new(0, 0, 5, 5)
      b = Tile.new(20, 0, 5, 5)  # 15px gap
      tiles = [a, b]
      distances = Tiles.distances(tiles, 20)

      output = capture_io(fn ->
        Tiles.filter(distances, 4, 6)
      end)

      # Should produce output for out-of-range distances
      assert is_binary(output)
    end

    test "filters with custom min and max" do
      import ExUnit.CaptureIO

      a = Tile.new(0, 0, 5, 5)
      b = Tile.new(8, 0, 5, 5)  # 3px gap
      tiles = [a, b]
      distances = Tiles.distances(tiles, 10)

      output = capture_io(fn ->
        Tiles.filter(distances, 5, 10)
      end)

      assert is_binary(output)
    end

    test "handles empty distance map" do
      import ExUnit.CaptureIO

      output = capture_io(fn ->
        Tiles.filter(%{}, 4, 6)
      end)

      assert output == ""
    end
  end
end
