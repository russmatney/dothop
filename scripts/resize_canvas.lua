
-- useful reference: Kacper's extension: https://thkaspar.itch.io/center-image
function center_sprite()
  local s = app.sprite
  for _, cel in ipairs(app.range.cels) do
    local x = cel.bounds.x
    local y = cel.bounds.y

    x = math.floor(s.width / 2) - math.floor(cel.bounds.width / 2)
    y = math.floor(s.height / 2) - math.floor(cel.bounds.height / 2)

    cel.position = Point(x, y)
  end
end

-- change_sprite_size --------------------------------------------------------------

function change_sprite_size(w, h)
  local s = app.sprite
  print("current sprite", s, s.width, s.height, s.pixelRatio)

  local longer

  if (w < h) then
    longer = h
  else
    longer = w
  end
  print("resizing", w, h, "longer: ", longer)

  -- resize to larger dimension
  app.command.SpriteSize({ui=false, width=longer, height=longer, lockRatio=true})
  print("resized sprite to longer: ", longer, s.width, s.height)

  center_sprite()

  -- crop shorter dimension
  local new_x = 0
  local new_y = 0
  local new_width = s.width
  local new_height = s.height

  if (w > h) then
    local extra_h = s.height - h
    new_y = extra_h / 2
    new_height = h
  else
    local extra_w = s.width - w
    new_x = extra_w / 2
    new_width = w
  end

  s:crop(new_x, new_y, new_width, new_height)
  print("cropped sprite", s.width, s.height)

  s:saveAs(s.filename)
  print("sprite re-saved")
end

-- main --------------------------------------------------------------

app.transaction(
  "main", function()
    local width = tonumber(app.params["width"])
    local height = tonumber(app.params["height"])

    change_sprite_size(width, height)
end)
