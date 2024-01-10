
-- change_sprite_size --------------------------------------------------------------

function change_sprite_size(w, h)
  local s = app.sprite
  print("current sprite", s, s.width, s.height, s.pixelRatio)

  local longer = w

  if (w < h) then
    longer = h
  end

  -- resize to larger dimension
  app.command.SpriteSize({ui=false, width=longer, height=longer, lockRatio=true})
  print("resized sprite", s.width, s.height)

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
    local width = app.params["width"]
    local height = app.params["height"]

    change_sprite_size(width, height)
end)
