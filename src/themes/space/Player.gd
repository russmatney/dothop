@tool
extends DotsPlayer

## vars #########################################################

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

## ready #########################################################

func _ready() -> void:
	super._ready()
	Anim.slide_in(self)
	anim.animation_finished.connect(on_anim_finished)

func on_anim_finished() -> void:
	if anim.animation == "moving":
		anim.play("floating")

## move #########################################################

func move_to_coord(coord: Vector2) -> void:
	anim.play("moving")
	super.move_to_coord(coord)

## move attempts #########################################################

func move_attempt_stuck(move_dir: Vector2) -> void:
	anim.play("moving")
	super.move_attempt_stuck(move_dir)

func move_attempt_away_from_edge(move_dir: Vector2) -> void:
	anim.play("moving")
	super.move_attempt_away_from_edge(move_dir)

func move_attempt_only_nulls(move_dir: Vector2) -> void:
	anim.play("moving")
	super.move_attempt_only_nulls(move_dir)
