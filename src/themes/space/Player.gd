@tool
extends DotHopPlayer

## vars #########################################################

var move_tween
var scale_tween
@onready var anim = $AnimatedSprite2D

## ready #########################################################

func _ready():
	super._ready()
	Anim.slide_in(self)
	anim.animation_finished.connect(on_anim_finished)

func on_anim_finished():
	if anim.animation == "moving":
		anim.play("shine")

## set_initial_coord #########################################################

func set_initial_coord(coord):
	current_coord = coord
	position = coord * square_size

func current_position():
	if current_coord != null:
		return current_coord * square_size
	else:
		return position

## move #########################################################

func move_to_coord(coord):
	anim.play("moving")
	# first, reset position
	position = current_position()

	current_coord = coord

	var target_pos = coord * square_size

	var t = 0.4
	move_tween = create_tween()
	move_tween.tween_property(self, "position", target_pos, t).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", 1.3*Vector2.ONE, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(self, "scale", 0.8*Vector2.ONE, t/4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(self, "scale", 1.0*Vector2.ONE, t/4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

## undo #########################################################

func undo_to_coord(coord):
	# first, reset position
	position = current_position()

	current_coord = coord
	var target_pos = coord * square_size

	var t = 0.3
	move_tween = create_tween()
	move_tween.tween_property(self, "position", target_pos, t).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

	scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", 0.8*Vector2.ONE, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(self, "scale", 1.0*Vector2.ONE, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

# undo-step for other player, but we're staying in the same coord
func undo_to_same_coord():
	var t = 0.3
	scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", 0.8*Vector2.ONE, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(self, "scale", 1.0*Vector2.ONE, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

## move attempts #########################################################

func move_attempt_stuck(move_dir:Vector2):
	anim.play("moving")
	var dist = 20.0
	var og_pos = current_position()
	var pos = move_dir * dist + current_position()
	var t = 0.4
	move_tween = create_tween()
	move_tween.tween_property(self, "position", pos, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	move_tween.tween_property(self, "position", og_pos, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", 1.3*Vector2.ONE, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(self, "scale", 1.0*Vector2.ONE, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func move_attempt_away_from_edge(move_dir:Vector2):
	anim.play("moving")
	var dist = 20.0
	var og_pos = current_position()
	var pos = move_dir * dist + current_position()
	var t = 0.4
	move_tween = create_tween()
	move_tween.tween_property(self, "position", pos, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	move_tween.tween_property(self, "position", og_pos, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", 1.3*Vector2.ONE, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(self, "scale", 1.0*Vector2.ONE, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func move_attempt_only_nulls(move_dir:Vector2):
	anim.play("moving")
	var dist = 20.0
	var og_pos = current_position()
	var pos = move_dir * dist + current_position()
	var t = 0.4
	move_tween = create_tween()
	move_tween.tween_property(self, "position", pos, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	move_tween.tween_property(self, "position", og_pos, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", 1.3*Vector2.ONE, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(self, "scale", 1.0*Vector2.ONE, t/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
