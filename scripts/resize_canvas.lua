
-- change_sprite_size --------------------------------------------------------------

function change_sprite_size(w, h)
  local s = app.sprite
  print("current sprite", s, s.width, s.height, s.pixelRatio)

  -- too basic (loses aspect ratio)
  -- s:resize(w, h)
  -- print("resized sprite", s, s.width, s.height)

  -- TODO handle w/h smaller than current sprite

  local extra_w = w - s.width
  local extra_h = h - s.height

  local left = extra_w / 2
  local right = extra_w / 2
  local top = extra_h / 2
  local bottom = extra_h / 2

  app.command.CanvasSize({ui=false, left=left, right=right, top=top, bottom=bottom})

  print("resized canvas")
  s:saveAs(s.filename)
end

-- main --------------------------------------------------------------

app.transaction(
  "main", function()
    local width = app.params["width"]
    local height = app.params["height"]

    change_sprite_size(width, height)
end)
