@tool
extends Marker2D
class_name PuzzleMapMarker

@export var world: PuzzleWorld

func _get_configuration_warnings() -> PackedStringArray:
	if world == null:
		return ["No world assigned!"]
	return []

func to_printable() -> Variant:
	return {world=world, "self"=str(self)}
