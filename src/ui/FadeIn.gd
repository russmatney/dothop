@tool
extends Node

@export var nodes: Array[Node] = []
@export var dur = 0.5

func _ready():
	for node in nodes:
		var t = get_tree().create_tween()
		node.modulate.a = 0.0
		t.tween_property(node, "modulate:a", 1.0, dur)
