@tool
extends Node2D
class_name DotHopPlayer

## vars #########################################################

@export var square_size: int = 32 :
	set(v):
		square_size = v
		render()

var display_name: String = "Player"

var label : RichTextLabel
var color_rect : ColorRect
var current_coord: Vector2

signal move_finished

## Log.pp #########################################################

func data() -> Dictionary:
	return {name=display_name, node=str(self), global_pos=self.get_global_position()}

## enter tree #########################################################

func _enter_tree() -> void:
	add_to_group("player", true)

## ready #########################################################

func _ready() -> void:
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
