@tool
extends Jumbotron
class_name PuzzleUnlocked

## vars ############################################################

var world: PuzzleWorld
@onready var icon_container: Control = $%IconContainer
@onready var icon: TextureRect = $%NextPuzzleIcon
@onready var bg_image: TextureRect = $%BackgroundTexture

## ready ############################################################

func _ready() -> void:
	if Engine.is_editor_hint():
		(bg_image.texture as AnimatedTexture).speed_scale = 1
	else:
		(bg_image.texture as AnimatedTexture).speed_scale = 3
	super._ready()

	render()

## build puzzle list ############################################################

func render() -> void:
	Sounds.play(Sounds.S.gong)

	if world:
		var td: PuzzleThemeData = world.get_theme_data()

		icon.set_texture(td.player_icon)
		header.text = "[center][color=crimson]%s[/color]\nUnlocked!" % world.get_display_name()

		var tag_line: bool = false
		# TODO support per puzzle set taglines
		# var tag_line = world.get_tag_line()
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
		icon.set_texture(Store.get_worlds()[0].get_theme_data().player_icon)

	if not Engine.is_editor_hint():
		animate_puzzle_icon()

	var delay: float = 0.3
	for node: CanvasItem in [header, icon, body]:
		node.modulate.a = 0
		Anim.fade_in(node, 1.0, delay)
		delay += 0.9

func animate_puzzle_icon() -> void:
	var og_pos: Vector2 = icon.position
	var og_scale: Vector2 = icon.scale
	var move_dist: float = 20

	icon.position = og_pos + Vector2.DOWN * move_dist/2

	var time: float = 0.9

	var t: Tween = create_tween()
	t.set_loops() # loop forever

	t.tween_property(icon, "position", og_pos + Vector2.DOWN * move_dist, time/2)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(icon, "scale", og_scale * 1.1, time/2)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	t.tween_property(icon, "position", og_pos, time/2)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.parallel().tween_property(icon, "scale", og_scale * 0.7, time/2)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
