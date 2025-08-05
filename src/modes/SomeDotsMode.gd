extends Node
class_name SomeDotsMode

## vars #####################################################################

@export var enabled: bool = true

var puzzle_node: DotHopPuzzle

## ready #####################################################################

func _ready() -> void:
	Events.puzzle_node.ready.connect(func(evt: Events.Evt) -> void:
		puzzle_node = evt.puzzle_node
		update_require_all_dots())

	Events.puzzle_node.win.connect(func(_evt: Events.Evt) -> void:
		notif_win_summary())

## toggle #####################################################################

func enable() -> void:
	enabled = true
	update_require_all_dots()
	Log.info("SomeDots enabled.")

func disable() -> void:
	enabled = false
	update_require_all_dots()
	Log.info("SomeDots disabled.")

func toggle() -> void:
	if enabled:
		disable()
	else:
		enable()

## win_summary #####################################################################

func notif_win_summary() -> void:
	if enabled:
		var dot_total := puzzle_node.state.dot_count()
		var undotted := puzzle_node.state.dot_count(true)
		var dots_hit := dot_total - undotted

		DotHop.notif("%s dots hit (of %s)" % [dots_hit, dot_total])

func update_require_all_dots() -> void:
	if puzzle_node:
		puzzle_node.set_require_all_dots(!enabled)
