@tool
extends CanvasLayer
class_name Credits

@export var credit_line_scene: PackedScene = preload("res://addons/core/credits/CreditLine.tscn")
@onready var credits_lines_container: VBoxContainer = $%CreditsLinesContainer
@onready var credits_scroll_container: ScrollContainer = $%CreditsScrollContainer

var pause_scroll_delay = 2.0
@onready var scroll_delay = pause_scroll_delay
var scroll_delay_per_line = 0.05
var since_last_scroll = 0

var added_lines = []

## ready ############################################################

func _ready():
	scroll_delay = pause_scroll_delay

	# clear lines
	for l in added_lines:
		credits_lines_container.remove_child(l)
		l.queue_free()

	added_lines = []

	for lines in get_credit_lines():
		var new_line = credit_line_scene.instantiate()
		new_line.text = "[center]\n"
		for line in lines:
			new_line.text += line + "\n"
		new_line.text += "[/center]"
		added_lines.append(new_line)
		credits_lines_container.add_child(new_line)

## input ############################################################

var scroll_direction = Vector2.ZERO

func _unhandled_input(event):
	if Trolls.is_move_up(event) or Trolls.is_restart(event):
		scroll_direction = Vector2.UP
	elif Trolls.is_move_down(event) or Trolls.is_close(event):
		scroll_direction = Vector2.DOWN
	if Trolls.is_move_released(event) or Trolls.is_close_released(event) \
		or Trolls.is_restart_released(event):
		scroll_direction = Vector2.ZERO

## process ############################################################

func _process(delta):
	if scroll_direction != Vector2.ZERO:
		match scroll_direction:
			Vector2.UP: credits_scroll_container.scroll_vertical -= 30
			Vector2.DOWN: credits_scroll_container.scroll_vertical += 30
		return

	if scroll_delay <= 0:
		if since_last_scroll <= 0:
			credits_scroll_container.scroll_vertical += 1
			since_last_scroll = scroll_delay_per_line
		else:
			since_last_scroll -= delta
	else:
		scroll_delay -= delta

## credits ############################################################

var credits = [
	["A game"],
	["Created for the some game jam"],
	["Made in Godot, Aseprite, and Emacs"],
]

# overwrite in children
func get_credit_lines():
	return credits
