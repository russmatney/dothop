extends CanvasLayer

@onready var world_list = $%WorldList

func _ready():
	set_focus()

func set_focus():
	world_list.set_focus()
