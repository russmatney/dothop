@tool
extends DotHopPlayer
class_name DotsPlayer

## vars #########################################################

var move_tween: Tween
var scale_tween: Tween

## ready #########################################################

func _ready() -> void:
	super._ready()
	# Anim.slide_in(self)

## set_initial_coord #########################################################

func set_initial_coord(coord: Vector2) -> void:
	current_coord = coord
	position = coord * square_size

# useful for starting/finishing points in animations
# overrides the node's position with current_coord, when possible
func current_position() -> Vector2:
	if current_coord != null:
		return current_coord * square_size
	else:
		return position

## move #########################################################

func move_to_coord(coord: Vector2) -> void:
	# first, reset position
	position = current_position()
	current_coord = coord

	# do we need special handling for this getting interrupted?
	# or will it move in lock-step?
	if (is_inside_tree()):
		var t := 0.4
		Anim.hop_to_coord(self, coord, t)

		get_tree().create_timer(t).timeout.connect(func() -> void:
			move_finished.emit())

## undo #########################################################

func undo_to_coord(coord: Vector2) -> void:
	# first, reset position
	position = current_position()

	current_coord = coord
	var t := 0.3
	Anim.hop_back(self, coord, t)

# undo-step for other player, but we're staying in the same coord
func undo_to_same_coord() -> void:
	Anim.scale_down_up(self, 0.3)

## move attempts #########################################################

var dist := 32.0
func move_attempt_stuck(move_dir:Vector2) -> void:
	var og_position := current_position()
	var target_position := move_dir * dist + og_position
	Anim.hop_attempt_pull_back(self, og_position, target_position, 0.4)

func move_attempt_away_from_edge(move_dir:Vector2) -> void:
	var og_position := current_position()
	var target_position := move_dir * dist + og_position
	Anim.hop_attempt_pull_back(self, og_position, target_position, 0.4)

func move_attempt_only_nulls(move_dir:Vector2) -> void:
	var og_position := current_position()
	var target_position := move_dir * dist + og_position
	Anim.hop_attempt_pull_back(self, og_position, target_position, 0.4)
