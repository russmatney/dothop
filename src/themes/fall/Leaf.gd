@tool
extends DotsDot

## vars ###########################################################

@onready var anim_green = $Green
@onready var anim_greenred = $GreenRed
@onready var anim_purple = $Purple
@onready var anim_redorange = $RedOrange
@onready var anim_yellow = $Yellow
@onready var anim_goal = $Goal

func all_anims() -> Array:
	return [anim_green, anim_greenred, anim_purple, anim_redorange, anim_yellow]

## ready ###########################################################

func _ready():
	hide_anims()
	anim = U.rand_of(all_anims())
	super._ready()

func hide_anims():
	all_anims().map(func(a): a.set_visible(false))
	anim_goal.set_visible(false)

## render ###########################################################

func render():
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
