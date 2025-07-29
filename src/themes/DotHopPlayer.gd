@tool
extends Node2D
class_name DotHopPlayer

## static

static func setup_player(p_state: PuzzleState.Player, theme_data: PuzzleThemeData) -> DotHopPlayer:
	var scene: PackedScene = PuzzleThemeData.get_player_scene(theme_data)
	var play: DotHopPlayer = scene.instantiate()
	play.state = p_state

	play.display_name = DHData.Legend.reverse_obj_map[DHData.Obj.Player]

	if theme_data:
		play.square_size = theme_data.square_size
	else:
		play.square_size = 32
	play.set_initial_coord(play.state.coord)

	return play

## vars #########################################################

var square_size: int = 32
var display_name: String = "Player"

var label : RichTextLabel
var color_rect : ColorRect
var current_coord: Vector2
var state: PuzzleState.Player

signal move_finished

## Log.pp #########################################################

func data() -> Dictionary:
	return {name=display_name, node=str(self), global_pos=self.get_global_position()}

## enter tree #########################################################

func _enter_tree() -> void:
	add_to_group("player", true)

## ready #########################################################

func _ready() -> void:
	if state != null:
		state.move_to_cell.connect(func(cell: PuzzleState.Cell) -> void: move_to_coord(cell.coord))
		state.undo_to_cell.connect(func(cell: PuzzleState.Cell) -> void: undo_to_coord(cell.coord))
		state.undo_to_same_cell.connect(func(_cell: PuzzleState.Cell) -> void: undo_to_same_coord())
		state.move_attempt_stuck.connect(func(dir: Vector2) -> void: move_attempt_stuck(dir))
	else:
		Log.warn("Player ready without assigned PuzzleState.Player!")

	U.set_optional_nodes(self, {label="ObjectLabel", color_rect="ColorRect"})
	render()

## render #########################################################

func render() -> void:
	if label != null:
		label.text = "[center]%s[/center]" % display_name
		label.custom_minimum_size = Vector2.ONE * square_size

	if color_rect != null:
		color_rect.size = Vector2.ONE * square_size
		color_rect.color = Color(0, 0, 1)

## set_initial_coord #########################################################

func set_initial_coord(coord: Vector2) -> void:
	current_coord = coord
	position = coord * square_size

## move #########################################################

func move_to_coord(coord: Vector2) -> void:
	current_coord = coord
	position = coord * square_size

	move_finished.emit()

## undo #########################################################

func undo_to_coord(coord: Vector2) -> void:
	current_coord = coord
	position = coord * square_size

# undo-step for other player, but we're staying in the same coord
func undo_to_same_coord() -> void:
	pass

## move attempts #########################################################

func move_attempt_stuck(_move_dir:Vector2) -> void:
	pass

func move_attempt_away_from_edge(_move_dir:Vector2) -> void:
	pass

func move_attempt_only_nulls(_move_dir:Vector2) -> void:
	pass
