extends Node
class_name Puzz

static func parse_game_def(path):
	# could make sure file exists
	var file = FileAccess.open(path, FileAccess.READ)
	var contents = file.get_as_text()
	var game = ParsedGame.new()
	var parsed = game.parse(contents)
	return parsed

static func parse_level_def(lines, msg=null):
	return ParsedGame.new().parse_level(lines, msg)

static func get_cell_objects(parsed, cell):
	if cell == null:
		return

	var objs = parsed.legend.get(cell)
	if objs != null:
		# duplicate, so the returned array doesn't share state with every other cell
		# (we mutate the returned state in level.gd as the game state)
		objs = objs.duplicate()

	# if or/and in objs, lookup again
	return objs