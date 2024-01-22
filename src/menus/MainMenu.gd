extends CanvasLayer

@onready var menu_list = $%MenuList

func _ready():
	set_focus()

func set_focus():
	menu_list.set_focus()
