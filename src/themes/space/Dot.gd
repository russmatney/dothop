@tool
extends DotHopDot

@onready var asteroid1: Node2D = $Asteroid1
@onready var asteroid2: Node2D = $Asteroid2
@onready var star: Node2D = $Star

## ready ###########################################################

func _ready() -> void:
	super._ready()

	var anims := [asteroid1, asteroid2, star]

	match type:
		DHData.dotType.Dot:
			anim = U.rand_of([asteroid1, asteroid2])
			anim.play("dot")
			U.set_random_frame(anim)
		DHData.dotType.Dotted:
			anim = U.rand_of([asteroid1, asteroid2])
			anim.play("dotted")
			U.set_random_frame(anim)
		DHData.dotType.Goal:
			anim = star
			anim.play("goal")
			U.set_random_frame(anim)

	for an: Node2D in anims:
		if anim != an:
			an.set_visible(false)
		else:
			an.set_visible(true)
