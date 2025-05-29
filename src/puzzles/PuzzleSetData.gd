@tool
extends Resource
class_name PuzzleSetData

@export_tool_button("Parse puzzle txt file") var parse_action: Variant = parse

@export var display_name: String
@export_file("*.txt") var path: String
var game_def: GameDef

## to pretty

func to_pretty() -> Variant:
	return [path, game_def]

## parse

func parse() -> void:
	game_def = GameDef.parse_game_def(path)
	Log.pr(self)

func parse_game_def() -> GameDef:
	game_def = GameDef.parse_game_def(path)
	return game_def

## helpers
