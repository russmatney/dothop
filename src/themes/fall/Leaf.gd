@tool
extends DotHopDot

## vars ###########################################################

@onready var anim_green: Node2D = $Green
@onready var anim_greenred: Node2D = $GreenRed
@onready var anim_purple: Node2D = $Purple
@onready var anim_redorange: Node2D = $RedOrange
@onready var anim_yellow: Node2D = $Yellow
@onready var anim_goal: Node2D = $Goal

func all_anims() -> Array:
	return [anim_green, anim_greenred, anim_purple, anim_redorange, anim_yellow]

## ready ###########################################################

func _ready() -> void:
	hide_anims()
	anim = U.rand_of(all_anims())
	super._ready()

func hide_anims() -> void:
	all_anims().map(func(a: Node2D) -> void: a.set_visible(false))
	anim_goal.set_visible(false)

## render ###########################################################

func render() -> void:
	if anim != null:
		match type:
			DHData.dotType.Dot:
				anim.set_visible(true)
				anim.play("twist")
				U.set_random_frame(anim)
				Anim.slide_in(self)
			DHData.dotType.Dotted:
				anim.set_visible(true)
				anim.play("dotted")
				U.set_random_frame(anim)
			DHData.dotType.Goal:
				hide_anims()
				anim_goal.set_visible(true)
