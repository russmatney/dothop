@tool
extends DotsDot

@onready var asteroid1 = $Asteroid1
@onready var asteroid2 = $Asteroid2
@onready var star = $Star

@onready var lightOccluder = $LightOccluder2D

## ready ###########################################################

func _ready():
	super._ready()

	var anims = [asteroid1, asteroid2, star]

	match type:
		DHData.dotType.Dot:
			anim = U.rand_of([asteroid1, asteroid2])
			anim.play("dot")
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

func render():
	if lightOccluder:
		match type:
			DHData.dotType.Dot:
				lightOccluder.set_occluder_light_mask(1)
			DHData.dotType.Dotted:
				lightOccluder.set_occluder_light_mask(0)
			DHData.dotType.Goal:
				lightOccluder.set_occluder_light_mask(1)

	super.render()
