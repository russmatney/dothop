@tool
extends Node

@export var nodes: Array[CanvasItem] = []
@export var dur: float = 0.5

func _ready() -> void:
	for node: CanvasItem in nodes:
		var t: Tween = create_tween()
		node.modulate.a = 0.0
		t.tween_property(node, "modulate:a", 1.0, dur)
