IHAT_X = 1
IHAT_Y = 0.5
JHAT_X = -1
JHAT_Y = 0.5

def tick(args)
  args.gtk.reset if args.inputs.keyboard.key_down.r

  set_defaults(args)

  handle_input(args)
  render_tiles(args)
  render_instructions(args)

  render_debug(args)
end

def set_defaults(args)
  args.state.tile_animation_offset_factor ||= 0
  args.state.animation_magnitude ||= 0
  args.state.scale ||= 1
  args.state.row_count ||= 1
  args.state.column_count ||= 1

  args.outputs.background_color = [30, 41, 59]
end

def render_tiles(args)
  args.state.tiles = build_tiles(args)

  args.outputs.sprites << args.state.tiles
end

def build_tiles(args)
  tick_count = args.state.tick_count

  animation_magnitude = args.state.animation_magnitude
  tile_animation_offset_factor = args.state.tile_animation_offset_factor

  sprite_width = 32
  sprite_height = 32
  sprite_path = "sprites/boxes/iso-box-slate.png"

  center = {x: args.grid.w.half, y: args.grid.h.half}

  scale = args.state.scale
  column_count = args.state.column_count
  row_count = args.state.row_count

  tile_grid_size = row_count * column_count
  tile_size = {w: sprite_width * scale, h: sprite_height * scale}

  x_origin = center.x - tile_size.w.half
  y_origin = center.y - tile_size.h.half - (tile_size.h * row_count).quarter

  tile_grid_center = {x: x_origin, y: y_origin}

  args.state.tile_grid_center = tile_grid_center

  tiles = tile_grid_size.times.to_a.map do |tile_number|
    column = tile_number % column_count
    row = tile_number.idiv(row_count)

    translated_coordinates = to_screen_coordinate(column: column, row: row, tile_size: tile_size)

    timing = tick_count + (tile_number * tile_animation_offset_factor)
    animation_offset = (Math.sin(timing.fdiv(10)) * animation_magnitude)

    {
      x: x_origin + translated_coordinates.x,
      y: y_origin + translated_coordinates.y + animation_offset,
      w: tile_size.w,
      h: tile_size.h,
      source_w: sprite_width,
      source_h: sprite_height,
      path: sprite_path,
      tile_number: tile_number
    }
  end

  first_tile = tiles.first
  first_tile[:path] = "sprites/boxes/iso-box-orange.png"

  args.outputs.solids << tiles if args.state.debug_grid

  # found_tiles = tiles.reverse.select do |tile|
  #   tile.intersect_rect?(args.inputs.mouse)
  # end

  # found_tile = found_tiles.last

  # if found_tile
  #   # $gtk.notify! "Tile Number: #{found_tile.x}"
  #   $gtk.set_system_cursor("hand")

  #   # found_tile.y += 2 * scale
  #   found_tile.path = "sprites/boxes/iso-box-orange.png"
  # else
  #   $gtk.set_system_cursor("arrow")
  # end

  tiles.reverse
end

def to_screen_coordinate(column:, row:, tile_size:)
  {
    x: column * IHAT_X * 0.5 * tile_size.w + row * JHAT_X * 0.5 * tile_size.w,
    y: column * IHAT_Y * 0.5 * tile_size.h + row * JHAT_Y * 0.5 * tile_size.h
  }
end

def handle_input(args)
  if args.inputs.keyboard.key_down.up
    args.state.animation_magnitude += 1
  elsif args.inputs.keyboard.key_down.down
    return if args.state.animation_magnitude <= 0
    args.state.animation_magnitude -= 1
  end

  if args.inputs.keyboard.key_down.right
    args.state.tile_animation_offset_factor += 1
  elsif args.inputs.keyboard.key_down.left
    return if args.state.tile_animation_offset_factor <= 1

    args.state.tile_animation_offset_factor -= 1
  end

  if args.inputs.keyboard.key_down.minus
    return if args.state.scale <= 1

    args.state.scale -= 1
  elsif args.inputs.keyboard.key_down.equal_sign
    args.state.scale += 1
  end

  if args.inputs.keyboard.key_down.zero
    args.state.scale = 1
    args.state.tile_animation_offset_factor = 0
    args.state.animation_magnitude = 0
  end

  if args.inputs.keyboard.key_down.close_square_brace
    args.state.row_count += 1
    args.state.column_count += 1
  elsif args.inputs.keyboard.key_down.open_square_brace
    return if args.state.row_count <= 1
    args.state.row_count -= 1
    args.state.column_count -= 1
  end

  if args.inputs.keyboard.key_down.tab
    args.state.debug_grid = !args.state.debug_grid
  end
end

def render_debug(args)
  args.outputs.labels << new_debug_line(top: 30, text: "FPS: #{args.gtk.current_framerate.to_sf}")
  args.outputs.labels << new_debug_line(top: 50, text: "Animation Offset: #{args.state.tile_animation_offset_factor}")
  args.outputs.labels << new_debug_line(top: 70, text: "Animation Magnitude: #{args.state.animation_magnitude}")
  args.outputs.labels << new_debug_line(top: 90, text: "Scale: #{args.state.scale}")
  args.outputs.labels << new_debug_line(top: 110, text: "Grid Size: #{args.state.row_count}x#{args.state.column_count}")

  background_height = 114
  background_top_padding = background_height + 25
  args.outputs.primitives << {x: 10.from_left, y: background_top_padding.from_top, w: 195, h: background_height, r: 30, g: 41, b: 59, a: 200, primitive_marker: :solid}

  if args.state.debug_grid
    top = args.grid.top
    bottom = args.grid.bottom
    left = args.grid.left
    right = args.grid.right

    center = {x: args.grid.w.half, y: args.grid.h.half}

    args.outputs.lines << [center.x, bottom, center.x, top, 255, 255, 255, 90]
    args.outputs.lines << [left, center.y, right, center.y, 255, 255, 255, 90]

    tile_grid_center = args.state.tile_grid_center

    yellow = [253, 224, 71, 255]
    args.outputs.lines << [tile_grid_center.x, bottom, tile_grid_center.x, top, *yellow]
    args.outputs.lines << [left, tile_grid_center.y, right, tile_grid_center.y, *yellow]
  end
end

def new_debug_line(top:, text:)
  [20.from_left, top.from_top, text, 0, 0, 255, 255, 255, 255, "fonts/OpenSans-MediumItalic.ttf"]
end

def render_instructions(args)
  args.outputs.labels << new_instruction_line(top: 30, text: "-/= to change scale")
  args.outputs.labels << new_instruction_line(top: 45, text: "[ or ] to change grid size")
  args.outputs.labels << new_instruction_line(top: 60, text: "Up/Down to change animation magnitude")
  args.outputs.labels << new_instruction_line(top: 75, text: "Left/Right to change animation offset")
  args.outputs.labels << new_instruction_line(top: 90, text: "0 (zero) to reset animation")

  background_height = 88
  background_top_padding = background_height + 25
  args.outputs.primitives << {x: 310.from_right, y: background_top_padding.from_top, w: 300, h: background_height, r: 30, g: 41, b: 59, a: 200, primitive_marker: :solid}
end

def new_instruction_line(top:, text:)
  [20.from_right, top.from_top, text.rjust(200), -4, 2, 255, 255, 255, 255, "fonts/PTMono-Regular.ttf"]
end
