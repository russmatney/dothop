extends CanvasLayer

@onready var world_list = $%WorldList
@onready var world_map = $%WorldMap

func _ready():
	world_list.button_focused.connect(on_button_focused)
	world_list.button_unfocused.connect(on_button_unfocused)
	set_focus()

func set_focus():
	world_list.set_focus()

func on_button_focused(_button, item):
	var markers = world_map.get_markers()
	for m in markers:
		if m.puzzle_set.get_entity_id() == item.puzzle_set.get_entity_id():
			world_map.current_marker = m
			return

func on_button_unfocused(_button, _item):
	world_map.current_marker = null
