@tool
extends DotHopDot

@onready var asteroid1 = $Asteroid1
@onready var asteroid2 = $Asteroid2
@onready var star = $Star
var anim: AnimatedSprite2D

## ready ###########################################################

func _ready():
	super._ready()
	Anim.slide_in(self)

	var anims = [asteroid1, asteroid2, star]

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

	for an in anims:
		if anim != an:
			an.set_visible(false)
		else:
			an.set_visible(true)

## render ###########################################################

func render():
	super.render()

	if anim != null:
		match type:
			DHData.dotType.Dot:
				anim.play("dot")
			DHData.dotType.Dotted:
				await get_tree().create_timer(0.4).timeout
				if type == DHData.dotType.Dotted: # if we're still dotted
					anim.play("dotted")
			DHData.dotType.Goal:
				anim.play("goal")
