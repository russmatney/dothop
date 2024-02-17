@tool
extends DotHopDot
class_name DotsDot

var anim

## ready ###########################################################

func _ready():
	var a = get_node_or_null("AnimatedSprite2D")
	if a:
		anim = a
	super._ready()
	Anim.slide_in(self)

## render ###########################################################

func render():
	super.render()

	if anim != null:
		match type:
			DHData.dotType.Dot:
				anim.play("dot")
				U.set_random_frame(anim)
			DHData.dotType.Dotted:
				await get_tree().create_timer(0.4).timeout
				if type == DHData.dotType.Dotted: # if we're still dotted
					anim.play("dotted")
					U.set_random_frame(anim)
			DHData.dotType.Goal:
				anim.play("goal")
				U.set_random_frame(anim)
