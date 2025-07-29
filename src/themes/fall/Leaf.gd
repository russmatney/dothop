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

func mark_goal() -> void:
	super.mark_goal()
	hide_anims()
	anim_goal.set_visible(true)

func mark_dotted() -> void:
	super.mark_dotted()
	anim.set_visible(true)
	anim.play("dotted")
	U.set_random_frame(anim)

func mark_undotted() -> void:
	super.mark_undotted()
	anim.set_visible(true)
	anim.play("twist")
	U.set_random_frame(anim)
	Anim.slide_in(self)
