@tool
extends DotHopDot
class_name DotsDot

var anim: AnimatedSprite2D

## ready ###########################################################

func _ready() -> void:
	var a: Variant = get_node_or_null("AnimatedSprite2D")
	if a:
		anim = a
	super._ready()

## render ###########################################################

func render() -> void:
	if anim != null:
		match type:
			DHData.dotType.Dot:
				set_z_index(1)
				anim.play("dot")
				U.set_random_frame(anim)
			DHData.dotType.Dotted:
				set_z_index(0)
				await get_tree().create_timer(0.4).timeout
				if type == DHData.dotType.Dotted: # if we're still dotted
					anim.play("dotted")
					U.set_random_frame(anim)
			DHData.dotType.Goal:
				set_z_index(0)
				anim.play("goal")
				U.set_random_frame(anim)
