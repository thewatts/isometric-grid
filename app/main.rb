def tick(args)
  args.state.tile_animation_offset_factor ||= 1
  args.state.animation_magnitude ||= 1
  args.state.scale ||= 1

  args.outputs.labels << [20.from_left, 30.from_top, "FPS: #{args.gtk.current_framerate.to_sf}", 0, 0, 255, 255, 255, 255]
  args.outputs.labels << [20.from_left, 55.from_top, "Animation Offset: #{args.state.tile_animation_offset_factor.to_sf}", 0, 0, 255, 255, 255, 255]
  args.outputs.labels << [20.from_left, 80.from_top, "Animation Magnitude: #{args.state.animation_magnitude.to_sf}", 0, 0, 255, 255, 255, 255]

  puts args.state.tick_count

  scale = args.state.scale

  width = 32
  height = 32

  grid_size = 10

  path = "sprites/boxes/iso-box-slate.png"

  tile_width = width * scale
  tile_height = height * scale

  starting_x = args.grid.w.half - (tile_width * grid_size.half) * scale
  starting_y = args.grid.h.half - (tile_width * grid_size.half) * scale

  size = grid_size * grid_size

  tiles = size.times.to_a.reverse.map do |tile_number|
    col = tile_number % grid_size
    row = tile_number.idiv(grid_size)

    original_x = starting_x + (col * tile_width)
    original_y = starting_y + (row * tile_height).quarter

    add_to_x = (row * -1 * tile_width.half)
    add_to_y = (col * tile_height.half).half

    x = original_x - (col * tile_width.half) + add_to_x + args.grid.w.quarter

    time = args.state.tick_count + tile_number * args.state.tile_animation_offset_factor
    y = original_y + add_to_y + args.grid.h.quarter + Math.sin(time.fdiv(10)) * args.state.animation_magnitude

    {
      x: x,
      y: y,
      w: width * scale,
      h: height * scale,
      source_x: 0,
      source_y: 0,
      source_w: width,
      source_h: height,
      path: path
    }
  end

  # found_tiles = tiles.select do |tile|
  #   tile.intersect_rect?(args.inputs.mouse)
  # end

  # found_tiles.last[:path] = "sprites/boxes/iso-box-orange.png" if found_tiles.any?

  background_color = [30, 41, 59]
  args.outputs.background_color = background_color
  args.outputs.sprites << tiles

  if args.inputs.keyboard.key_down.up
    args.state.tile_animation_offset_factor += 1
  elsif args.inputs.keyboard.key_down.down
    return if args.state.tile_animation_offset_factor <= 1
    args.state.tile_animation_offset_factor -= 1
  end

  if args.inputs.keyboard.key_down.right
    args.state.animation_magnitude += 1
  elsif args.inputs.keyboard.key_down.left
    return if args.state.animation_magnitude <= 0
    args.state.animation_magnitude -= 1
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
end
