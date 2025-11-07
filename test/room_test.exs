defmodule RoomTest do
  use ExUnit.Case

  alias Vix.Vips.Image

  describe "Room.new!/3" do
    test "creates room with default options" do
      image = Room.new!(2500, 2500)
      assert %Image{} = image
      assert Image.width(image) > 0
      assert Image.height(image) > 0
    end

    test "creates room with custom spacer" do
      image = Room.new!(2500, 2500, spacer: 6)
      assert %Image{} = image
    end

    test "creates room with verbose level 0" do
      image = Room.new!(2500, 2500, verbose: 0)
      assert %Image{} = image
    end

    test "creates room with verbose level 1" do
      image = Room.new!(2500, 2500, verbose: 1)
      assert %Image{} = image
    end

    test "creates room with verbose level 2" do
      image = Room.new!(2500, 2500, verbose: 2)
      assert %Image{} = image
    end

    test "creates room with verbose level 3" do
      image = Room.new!(2500, 2500, verbose: 3)
      assert %Image{} = image
    end

    test "creates room with verbose level 4" do
      image = Room.new!(2500, 2500, verbose: 4)
      assert %Image{} = image
    end

    test "creates room with truncate true" do
      image = Room.new!(1200, 1200, truncate: true)
      assert %Image{} = image
      assert Image.width(image) == 1200
      assert Image.height(image) == 1200
    end

    test "creates room with truncate false" do
      image = Room.new!(2500, 2500, truncate: false)
      assert %Image{} = image
      # With truncate false, dimensions might differ from input
    end

    test "creates room with offset" do
      image = Room.new!(2500, 2500, offset: 10)
      assert %Image{} = image
    end

    test "creates room with offset_x" do
      image = Room.new!(2500, 2500, offset_x: 20)
      assert %Image{} = image
    end

    test "creates room with offset_y" do
      image = Room.new!(2500, 2500, offset_y: 30)
      assert %Image{} = image
    end

    test "creates room with both offset_x and offset_y" do
      image = Room.new!(2500, 2500, offset_x: 15, offset_y: 25)
      assert %Image{} = image
    end

    test "creates room with multiple options combined" do
      image = Room.new!(1500, 1500, spacer: 5, verbose: 3, truncate: true, offset_x: 10, offset_y: 10)
      assert %Image{} = image
    end

    test "creates small room" do
      image = Room.new!(1300, 1300, truncate: true)
      assert %Image{} = image
    end

    test "creates large room" do
      image = Room.new!(3000, 3000)
      assert %Image{} = image
    end

    test "creates rectangular room (width > height)" do
      image = Room.new!(3000, 2500)
      assert %Image{} = image
    end

    test "creates rectangular room (height > width)" do
      image = Room.new!(2500, 3000)
      assert %Image{} = image
    end
  end
end
