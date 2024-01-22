@tool
extends Node2D

@onready var map = $%MapSprite

@export var current_marker: Marker2D = null :
	set(marker):
		current_marker = marker
		center_map()


func center_map():
	var pos = Vector2(0, 0)
	if current_marker != null:
		pos = current_marker.position * -1

	# TODO animate
	map.position = pos
