# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

**Tiles** is an Elixir library for working with axis-aligned tiles (rectangles). It provides utilities for arranging tiles in repeating patterns, calculating adjacency relationships, and rendering visual representations of tile layouts using libvips (via the Vix library).

The primary use case is generating tiled floor patterns with various tile dimensions (203x203, 406x406, 203x406, 610x406mm) arranged in a complex repeating pattern.

## Key Commands

### Testing
```bash
# Run all tests
mix test

# Run a specific test file
mix test test/tile_test.exs

# Run tests with coverage
mix test --cover

# Run a specific test by line number
mix test test/tiles_test.exs:8
```

### Formatting
```bash
# Format code according to project standards
mix format

# Check if files are formatted
mix format --check-formatted
```

### Dependencies
```bash
# Install/update dependencies
mix deps.get

# Clean and recompile everything
mix deps.clean --all && mix deps.get && mix compile
```

### Interactive Development
```bash
# Start IEx with project loaded
iex -S mix

# Run the Livebook notebook
livebook server patterns.livemd
```

## Architecture

### Core Modules

**`Tile`** (`lib/tile.ex`)
- Defines the fundamental rectangle struct with fields: `id`, `i` (index), `x`, `y`, `width`, `height`, `dx`, `dy` (offsets)
- Provides constructors with validation (enforces non-negative dimensions)
- Implements overlap detection between tiles
- Implements `String.Chars` protocol for debugging output

**`Tiles`** (`lib/tiles.ex`)
- Main logic module containing pattern generation and spatial analysis
- `pattern/1`: Defines the 12-cell repeating pattern with various tile sizes
- `arrange/4`: Places pattern tiles across a room area (with cycling if needed)
- `find_adjacent/2`: Identifies adjacent tiles within a tolerance (default 10px)
- `distances/2`: Calculates gaps between adjacent tiles for spacing validation
- `dimensions/1`: Computes bounding box dimensions
- `bounding_box/1`: Returns the enclosing rectangle for a set of tiles

**`Color`** (`lib/color.ex`)
- Assigns colors to tiles from a 6-color palette based on tile index
- Used for visual differentiation in rendered output

**`Room`** (`lib/room.ex`)
- Renders tile layouts as images using Vix (libvips wrapper)
- `new!/3`: Creates a room image with specified dimensions and options
- Overlays text on tiles (dimensions, indices, positions) based on verbosity level
- Composites tiles with spacing annotations showing distances between adjacent tiles
- Options: `:spacer`, `:verbose`, `:truncate`, `:offset_x`, `:offset_y`

### Pattern System

The tile pattern is a 12-cell repeating unit that tiles a room:
- Pattern dimensions are derived from the arranged tiles
- Pattern contains tiles of 5 size types with specific positions
- The `arrange/4` function repeats this pattern across the room dimensions
- Tiles cycle through the pattern if insufficient unique tiles are provided

### Adjacency & Distance Calculations

The library has sophisticated spatial analysis:
- **Adjacency**: Two tiles are adjacent if their edges are within tolerance AND they overlap on the perpendicular axis
- **Distances**: Returns a map of `{index, [{adjacent_index, [dx, dy]}]}` where dx/dy represent gaps
- Used to validate proper spacing in tile layouts and identify installation issues

## Development Notes

### Dependencies
- **Elixir ~> 1.18**: Modern Elixir version required
- **Vix ~> 0.5**: Elixir wrapper for libvips image processing library

### Testing Strategy
- Unit tests in `test/tile_test.exs` cover basic Tile operations
- Integration tests in `test/tiles_test.exs` cover pattern generation and spatial algorithms
- Test data helpers in `test/test_data.exs`

### Image Generation
Room rendering uses libvips for high-performance image composition:
- Creates RGB images with colored tiles
- Text overlays use "Lucida Console" font at 200 DPI
- Compositing uses `VIPS_BLEND_MODE_OVER` for proper alpha blending

### Livebook Notebook
The `patterns.livemd` notebook provides interactive visualization:
- Run with `livebook server patterns.livemd`
- Demonstrates room generation with configurable parameters
- Useful for visual debugging and exploring pattern variations
