@tool
extends DotHopDot

## vars ###########################################################

@onready var anim_green = $Green
@onready var anim_greenred = $GreenRed
@onready var anim_purple = $Purple
@onready var anim_redorange = $RedOrange
@onready var anim_yellow = $Yellow
@onready var anim_goal = $Goal

func all_anims() -> Array:
	return [anim_green, anim_greenred, anim_purple, anim_redorange, anim_yellow]

## config warnings ###########################################################

func _get_configuration_warnings():
	return super._get_configuration_warnings()

## ready ###########################################################

var anim

func _ready():
	hide_anims()
	anim = U.rand_of(all_anims())
	super._ready()
	animate_entry()

func hide_anims():
	all_anims().map(func(a): a.set_visible(false))
	anim_goal.set_visible(false)

## render ###########################################################

func render():
	super.render()

	if anim != null:
		match type:
			DHData.dotType.Dot:
				anim.set_visible(true)
				anim.play("twist")
				animate_entry()
			DHData.dotType.Dotted:
				var t = 0.4
				animate_exit(t)
				await get_tree().create_timer(t).timeout
				if type == DHData.dotType.Dotted: # if we're still dotted
					anim.set_visible(false)
				else:
					render()
			DHData.dotType.Goal:
				hide_anims()
				anim_goal.set_visible(true)

## entry animation ###########################################################

var entry_tween
var entry_t = 0.3
func animate_entry():
	var og_position = current_position()
	position = position - Vector2.ONE * 10
	scale = Vector2.ONE * 0.5
	entry_tween = create_tween()
	entry_tween.tween_property(self, "scale", Vector2.ONE, entry_t)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	entry_tween.parallel().tween_property(self, "position", og_position, entry_t)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	entry_tween.parallel().tween_property(self, "modulate:a", 1.0, entry_t)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func animate_exit(t):
	position = current_position()
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE * 0.5, t)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "position", position - Vector2.ONE * 10, t)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "modulate:a", 0.0, t)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
