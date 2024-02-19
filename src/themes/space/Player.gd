@tool
extends DotsPlayer

## vars #########################################################

@onready var anim = $AnimatedSprite2D

## ready #########################################################

func _ready():
	super._ready()
	Anim.slide_in(self)
	anim.animation_finished.connect(on_anim_finished)

func on_anim_finished():
	if anim.animation == "moving":
		anim.play("shine")

## move #########################################################

func move_to_coord(coord):
	anim.play("moving")
	return super.move_to_coord(coord)

## move attempts #########################################################

func move_attempt_stuck(move_dir:Vector2):
	anim.play("moving")
	super.move_attempt_stuck(move_dir)

func move_attempt_away_from_edge(move_dir:Vector2):
	anim.play("moving")
	super.move_attempt_away_from_edge(move_dir)

func move_attempt_only_nulls(move_dir:Vector2):
	anim.play("moving")
	super.move_attempt_only_nulls(move_dir)
