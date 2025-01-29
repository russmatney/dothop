@tool
extends Jumbotron
class_name PuzzleUnlocked

## vars ############################################################

var puzzle_set: PuzzleSet
@onready var icon_container = $%IconContainer
@onready var icon = $%NextPuzzleIcon
@onready var bg_image = $%BackgroundTexture

## ready ############################################################

func _ready():
	if Engine.is_editor_hint():
		bg_image.texture.speed_scale = 1
	else:
		bg_image.texture.speed_scale = 3
	super._ready()

	render()

## build puzzle list ############################################################

func render():
	Sounds.play(Sounds.S.gong)

	if puzzle_set:
		var _theme = puzzle_set.get_theme()

		icon.set_texture(_theme.get_player_icon())

		header.text = "[center][color=crimson]%s[/color]\nUnlocked!" % puzzle_set.get_display_name()

		var tag_line = false
		# TODO support per puzzle set taglines
		# var tag_line = puzzle_set.get_tag_line()
		if tag_line:
			body.text = "[center]%s" % tag_line
		else:
			body.text = "[center]%s" % U.rand_of([
				"Moving on up in the world!",
				"You rock the house!",
				"You're out of this world!",
				"Dang, you must be wicked smart!",
				"I'm seriously so proud of you :)",
				"Well done indeed!",
				])
	else:
		header.text = "[center]Dang, that was the [color=crimson]last puzzle[/color]!"
		body.text = "[center]Congrations,\nand thanks for playing!"
		icon.set_texture(Store.get_puzzle_sets()[0].get_theme().get_player_icon())

	if not Engine.is_editor_hint():
		animate_puzzle_icon()

	var delay = 0.3
	for node in [header, icon, body]:
		animate_fade_in(node, delay)
		delay += 0.9

	animate_fade_in(dismiss_input_icon, delay + 2)

func animate_fade_in(node, delay=0):
	var t = create_tween()
	var dur = 0.4

	node.modulate.a = 0
	t.tween_property(node, "modulate:a", 1.0, dur)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)\
		.set_delay(delay)

func animate_puzzle_icon():
	var og_pos = icon.position
	var og_scale = icon.scale
	var move_dist = 20

	icon.position = og_pos + Vector2.DOWN * move_dist/2

	var time = 0.9

	var t = create_tween()
	t.set_loops() # loop forever

	t.tween_property(icon, "position", og_pos + Vector2.DOWN * move_dist, time/2)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(icon, "scale", og_scale * 1.1, time/2)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	t.tween_property(icon, "position", og_pos, time/2)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(icon, "scale", og_scale * 0.7, time/2)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
