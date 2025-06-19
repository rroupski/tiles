defmodule Room do
  alias Vix.Vips.Image
  alias Vix.Vips.Operation

  @text_dpi 200
  @text_font "Lucida Console"
  @background_color [0xFF, 0xFF, 0xFF]

  @default_spacer 3

  def new!(width, height, spacer \\ @default_spacer) do
    pattern = FrenchPattern.new(spacer)

    tiles = Tiles.arrange(pattern, width, height)
    tuples = tiles |> List.to_tuple()

    # Calculate the distances between the tiles in the room
    distances = Tiles.distances(tiles)

    floor = Image.build_image!(width, height, @background_color)

    List.foldl(tiles, floor, fn tile, acc ->
      composite =
        Image.build_image!(tile.width, tile.height, tile_color(tile, pattern))
        |> build_tile(tile, tuples, Map.get(distances, tile.i))

      Operation.composite2!(
        acc,
        composite,
        :VIPS_BLEND_MODE_OVER,
        x: tile.x,
        y: tile.y
      )
    end)
  end

  def new(width, height, spacer \\ @default_spacer) do
    pattern = FrenchPattern.new(spacer)

    tiles = Tiles.arrange(pattern, width, height)

    # Calculate the distances between the tiles in the room
    distances = Tiles.distances_ex(tiles)

    floor = Image.build_image!(width, height, [0xFF, 0xFF, 0xFF])

    List.foldl(tiles, floor, fn tile, acc ->
      img = Image.build_image!(tile.width, tile.height, tile_color(tile, pattern))

      tile_text = tile_title(tile)

      adjacency = inspect(Map.get(distances, tile.i))
      list = String.slice(adjacency, 1, String.length(adjacency) - 2)
      number_text = embed_text("#{list}")

      composite =
        Operation.composite!(
          [img, tile_text, number_text],
          [:VIPS_BLEND_MODE_OVER, :VIPS_BLEND_MODE_OVER],
          x: [0, 0],
          y: [0, 0]
        )

      Operation.composite2!(acc, composite, :VIPS_BLEND_MODE_OVER,
        x: tile.x,
        y: tile.y
      )
    end)
  end

  defp tile_title(tile) do
    embed_text(tile, "#{tile.i}\n#{tile.width}x#{tile.height}")
  end

  defp tile_color(tile, pattern) do
    [
      127 + Integer.mod(tile.i + Color.new(pattern, 0xAA, tile.x, tile.y), 127),
      127 + Integer.mod(tile.i + Color.new(pattern, 0xAA, tile.x, tile.y), 127),
      127 + Integer.mod(tile.i + Color.new(pattern, 0x99, tile.x, tile.y), 127)
    ]
  end

  defp embed_text(text) do
    # Create high-quality text overlay with anti-aliasing
    {img, _} =
      Operation.text!(
        text,
        dpi: @text_dpi,
        font: @text_font,
        rgba: true
      )

    img
  end

  defp embed_text(tile, s) do
    # Create high-quality text overlay with anti-aliasing
    {text, _} =
      Operation.text!(
        s,
        dpi: @text_dpi,
        font: @text_font,
        rgba: true
      )

    # Position text precisely on the image
    # The embed operation handles proper padding and positioning
    Operation.embed!(
      text,
      div(tile.width - Image.width(text), 2),
      div(tile.height - Image.height(text), 2),
      tile.width,
      tile.height
    )
  end

  defp build_tile(img, tile) do
    tile_text = tile_title(tile)

    {
      [img, tile_text],
      [:VIPS_BLEND_MODE_OVER],
      [div(tile.width - Image.width(tile_text), 2)],
      [div(tile.height - Image.height(tile_text), 2)]
    }
  end

  defp build_tile(img, tile, _tuples, nil) do
    {i, m, x, y} = build_tile(img, tile)

    Operation.composite!(i, m, x: x, y: y)
  end

  defp build_tile(img, tile, tuples, distances) do
    {i, m, x, y} =
      Enum.reduce(distances, {[], [], [], []}, fn {id, [dx, dy]}, {i, m, x, y} = acc ->
        adj = elem(tuples, id)

        if dx > 0 do
          xx =
            if adj.x > tile.x do
              tile.width - 32
            else
              2
            end

          yy = middle_y(tile, adj)

          # IO.puts("dx: #{tile.i} --> #{adj.i}: #{xx}x#{yy}")

          {
            [embed_text(Integer.to_string(dx)) | i],
            [:VIPS_BLEND_MODE_OVER | m],
            [xx | x],
            [yy | y]
          }
        else
          if dy > 0 do
            xx = middle_x(tile, adj)

            yy =
              if adj.y > tile.y do
                tile.height - 32
              else
                0
              end

            # IO.puts("dy: #{tile.i} --> #{adj.i}: #{xx}x#{yy}")

            {
              [embed_text(Integer.to_string(dy)) | i],
              [:VIPS_BLEND_MODE_OVER | m],
              [xx | x],
              [yy | y]
            }
          else
            acc
          end
        end
      end)

    tile_text = embed_text(tile, "#{tile.i}\n#{tile.width}x#{tile.height}")

    i = [img, tile_text | i]
    m = [:VIPS_BLEND_MODE_OVER | m]
    x = [div(tile.width - Image.width(tile_text), 2) | x]
    y = [div(tile.height - Image.height(tile_text), 2) | y]

    Operation.composite!(i, m, x: x, y: y)
  end

  # Find the middle of the overlapping section of two horizontal line segments
  defp middle_x(t1, t2) do
    overlap_start = max(t1.x, t2.x)
    overlap_end = min(t1.x + t1.width, t2.x + t2.width)

    if overlap_end <= overlap_start do
      0
    else
      div(overlap_start + overlap_end, 2) - t1.x
    end
  end

  # Find the middle of the overlapping section of two vertical line segments
  defp middle_y(t1, t2) do
    overlap_start = max(t1.y, t2.y)
    overlap_end = min(t1.y + t1.height, t2.y + t2.height)

    if overlap_end <= overlap_start do
      0
    else
      div(overlap_start + overlap_end, 2) - t1.y
    end
  end
end
