@tool
extends Marker2D
class_name PuzzleMapMarker

@export var puzzle_set: PuzzleSet

func _get_configuration_warnings():
	if puzzle_set == null:
		return ["No puzzle_set assigned!"]
	return []

func to_pretty(a, b, c):
	return Log.to_pretty({puzzle_set=puzzle_set, "self"=str(self)}, a, b, c)
