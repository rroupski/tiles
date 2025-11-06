defmodule Room do
  alias Vix.Vips.Image
  alias Vix.Vips.Operation

  # Tile description text size
  @tile_text_dpi 200

  # Tile gap width text size of offsets
  @gap_text_dpi 400
  @gap_text_x_offset 36
  @gap_text_y_offset 50

  @tile_text_font "IBM Plex Mono"
  @background_color [0xFF, 0xFF, 0xFF]

  def new!(width, height, options \\ []) do
    spacer = Keyword.get(options, :spacer, 3)
    verbose = Keyword.get(options, :verbose, 2)
    truncate = Keyword.get(options, :truncate, false)

    offset = Keyword.get(options, :offset, 0)
    offset_x = Keyword.get(options, :offset_x, offset)
    offset_y = Keyword.get(options, :offset_y, offset)

    pattern = Tiles.new(spacer)

    tiles = Tiles.arrange(pattern, width, height, truncate)

    # Calculate the distances between the tiles in the room
    distances = Tiles.distances(tiles)

    {width, height} =
      if truncate do
        {width, height}
      else
        box = Tiles.bounding_box(tiles)
        {box.width - offset_x, box.height - offset_y}
      end

    floor = Image.build_image!(width, height, @background_color)

    tuples = tiles |> List.to_tuple()

    List.foldl(tiles, floor, fn tile, acc ->
      composite =
        Image.build_image!(tile.width, tile.height, tile_color(tile))
        |> build_tile(tile, tuples, Map.get(distances, tile.i), verbose)

      Operation.composite2!(
        acc,
        composite,
        :VIPS_BLEND_MODE_OVER,
        x: tile.x - offset_x,
        y: tile.y - offset_y
      )
    end)
  end

  defp tile_color(tile) do
    Color.new(tile)
  end

  defp embed_text(text) do
    # Tile gap text: Create high-quality text overlay with anti-aliasing
    {img, _} =
      Operation.text!(
        text,
        dpi: @gap_text_dpi,
        font: @tile_text_font,
        rgba: true
      )

    img
  end

  defp embed_text(tile, s) do
    # Tile title text: Create high-quality text overlay with anti-aliasing
    {text, _} =
      Operation.text!(
        s,
        dpi: @tile_text_dpi,
        font: @tile_text_font,
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

  defp build_tile(img, tile, verbose) do
    tile_text = text(tile, verbose)

    {
      [img, tile_text],
      [:VIPS_BLEND_MODE_OVER],
      [div(tile.width - Image.width(tile_text), 2)],
      [div(tile.height - Image.height(tile_text), 2)]
    }
  end

  defp build_tile(img, tile, _tuples, nil, verbose) do
    {i, m, x, y} = build_tile(img, tile, verbose)

    Operation.composite!(i, m, x: x, y: y)
  end

  defp build_tile(img, tile, tuples, distances, verbose) do
    {i, m, x, y} =
      Enum.reduce(distances, {[], [], [], []}, fn {id, [dx, dy]}, {i, m, x, y} = acc ->
        adj = elem(tuples, id)

        if dx > 0 do
          xx =
            if adj.x > tile.x do
              tile.width - @gap_text_x_offset
            else
              2
            end

          yy = middle_y(tile, adj)

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
                tile.height - @gap_text_y_offset
              else
                2
              end

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

    tile_text =
      cond do
        verbose == 0 ->
          embed_text(tile, "#{tile.id}")

        verbose == 1 ->
          embed_text(tile, "#{tile.i}")

        verbose == 2 ->
          embed_text(tile, "#{tile.width}x#{tile.height}")

        verbose == 3 ->
          embed_text(tile, "#{tile.i}\n#{tile.width}x#{tile.height}")

        verbose == 4 ->
          embed_text(tile, "#{tile.i}\n#{tile.width}x#{tile.height}\n[#{tile.x},#{tile.y}]")

        true ->
          nil
      end

    {i, m, x, y} =
      if tile_text != nil do
        {[img, tile_text | i], [:VIPS_BLEND_MODE_OVER | m],
         [div(tile.width - Image.width(tile_text), 2) | x],
         [div(tile.height - Image.height(tile_text), 2) | y]}
      else
        {[img | i], m, x, y}
      end

    Operation.composite!(i, m, x: x, y: y)
  end

  defp text(tile, verbose) do
    cond do
      verbose == 0 ->
        embed_text(tile, "#{tile.id}")

      verbose == 1 ->
        embed_text(tile, "#{tile.i}")

      verbose == 2 ->
        embed_text(tile, "#{tile.width}x#{tile.height}")

      verbose == 3 ->
        embed_text(tile, "#{tile.i}\n#{tile.width}x#{tile.height}")

      verbose == 4 ->
        embed_text(tile, "#{tile.i}\n#{tile.width}x#{tile.height}\n[#{tile.x},#{tile.y}]")

      true ->
        nil
    end
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
