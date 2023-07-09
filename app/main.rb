def tick(args)
  args.gtk.reset if args.inputs.keyboard.key_down.r

  set_defaults(args)

  process_input(args)

  tiles = build_tiles(args)

  args.outputs.background_color = [30, 41, 59]
  args.outputs.sprites << tiles

  debug(args)
  instructions(args)
end

def set_defaults(args)
  args.state.tile_animation_offset_factor ||= 1
  args.state.animation_magnitude ||= 1
  args.state.scale ||= 1
  args.state.row_count ||= 1
  args.state.column_count ||= 1
end

def build_tiles(args)
  tile_animation_offset_factor = args.state.tile_animation_offset_factor
  animation_magnitude = args.state.animation_magnitude
  tick_count = args.state.tick_count
  scale = args.state.scale
  column_count = args.state.column_count
  row_count = args.state.row_count

  sprite_width = 32
  sprite_height = 32
  sprite_path = "sprites/boxes/iso-box-slate.png"

  grid_size = row_count * column_count

  tile_width = sprite_width * scale
  tile_height = sprite_height * scale

  center = args.grid.w.half
  middle = args.grid.h.half

  starting_x = center - tile_width.half
  starting_y = middle - tile_height.half - (tile_height.half * row_count).half

  tiles = grid_size.times.to_a.map do |tile_number|
    column = tile_number % column_count
    row = tile_number.idiv(row_count)

    x = starting_x + (tile_width.half * column) - (tile_width.half * row)
    y = starting_y + (tile_height.quarter * row) + (tile_height.quarter * column)

    timing = tick_count + (tile_number * tile_animation_offset_factor)
    animation_offset = (Math.sin(timing.fdiv(10)) * animation_magnitude)

    y += animation_offset

    {
      x: x,
      y: y,
      w: sprite_width * scale,
      h: sprite_height * scale,
      source_w: sprite_width,
      source_h: sprite_height,
      path: sprite_path,
      tile_number: tile_number
    }
  end

  first_tile = tiles.first
  first_tile[:path] = "sprites/boxes/iso-box-orange.png"

  # found_tiles = tiles.reverse.select do |tile|
  #   tile.intersect_rect?(args.inputs.mouse)
  # end

  # found_tiles.last[:path] = "sprites/boxes/iso-box-orange.png" if found_tiles.any?

  tiles.reverse
end

def process_input(args)
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
    args.state.tile_animation_offset_factor = 1
    args.state.animation_magnitude = 1
  end

  if args.inputs.keyboard.key_down.close_square_brace
    args.state.row_count += 1
    args.state.column_count += 1
  elsif args.inputs.keyboard.key_down.open_square_brace
    return if args.state.row_count <= 1
    args.state.row_count -= 1
    args.state.column_count -= 1
  end
end

def debug(args)
  args.outputs.labels << new_debug_line(top: 30, text: "FPS: #{args.gtk.current_framerate.to_sf}")
  args.outputs.labels << new_debug_line(top: 50, text: "Animation Offset: #{args.state.tile_animation_offset_factor}")
  args.outputs.labels << new_debug_line(top: 70, text: "Animation Magnitude: #{args.state.animation_magnitude}")
  args.outputs.labels << new_debug_line(top: 90, text: "Scale: #{args.state.scale}")
  args.outputs.labels << new_debug_line(top: 110, text: "Grid Size: #{args.state.row_count}x#{args.state.column_count}")

  background_height = 114
  background_top_padding = background_height + 25
  args.outputs.primitives << {x: 10.from_left, y: background_top_padding.from_top, w: 195, h: background_height, r: 30, g: 41, b: 59, a: 200, primitive_marker: :solid}
end

def new_debug_line(top:, text:)
  [20.from_left, top.from_top, text, 0, 0, 255, 255, 255, 255, "fonts/OpenSans-MediumItalic.ttf"]
end

def instructions(args)
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
