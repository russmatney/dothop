
-- change_sprite_size --------------------------------------------------------------

function change_sprite_size(w, h)
  print("resizing! ", w, h)

  local s = app.sprite
  print("current sprite", s, s.width, s.height)

  s:resize(w, h)
  s:saveAs(s.filename)
end

-- main --------------------------------------------------------------

app.transaction(
  "main", function()
    local width = app.params["width"]
    local height = app.params["height"]

    change_sprite_size(width, height)
end)
