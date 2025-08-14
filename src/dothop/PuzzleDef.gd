@tool
extends Resource
class_name PuzzleDef

# helpful for supporting some tests
static func parse(lines: Array) -> PuzzleDef:
	return PuzzleDef.new(ParsedGame.new().parse_puzzle(lines) as Dictionary)

## vars ########################################3333

@export var og_shape: Array
@export var shape: Array
@export var width: int
@export var height: int
@export var og_height: int
@export var idx: int
@export var world_short_name: String
@export var meta: Dictionary
@export var message: String

@export var analysis: PuzzleAnalysis

var is_completed: bool
var is_skipped: bool


func to_pretty() -> Variant:
	return {id=get_id(), idx=idx,
		shape=shape,
		width=width, height=height,
		meta=meta,
		message=message,
		# is_completed=is_completed, is_skipped=is_skipped,
		}

## init ########################################3333

func _init(raw: Dictionary={}, parsed_game: ParsedGame = null) -> void:
	if len(raw) == 0:
		return
	if raw.shape:
		shape = raw.shape
		og_shape = shape.duplicate()
	width = raw.width
	height = raw.height
	og_height = raw.height
	meta = raw.meta
	if "message" in raw:
		message = raw.message
	if "idx" in raw:
		idx = raw.idx
	if parsed_game and "short_name" in parsed_game.prelude:
		world_short_name = parsed_game.prelude.get("short_name", "unknown")

## get_id ################################################

func get_id() -> String:
	if meta and "id" in meta:
		return meta.id
	else:
		return get_label()

func get_label() -> String:
	return "%s-%s" % [world_short_name, idx + 1]

# could this be deterministic? a 'proper' orientation of a xxx/..t/ooo?
# yes - we could sort by a hash/checksum and just use the 'first' in that list
## the term 'FEN' is borrowed from chess
func get_fen() -> String:
	# TODO find a deterministic id based on the shape to get 'transpositions'
	return "/".join(shape.map(func(row: Array) -> String:
		return "".join(row.map(func(cell: Variant) -> String:
			return str(cell) if cell != null else "."
		)))
	)

## all_coords ####################################################

func all_coords() -> Array[Vector2]:
	var coords: Array[Vector2] = []
	for y in range(len(shape)):
		for x in range(len(shape[y])):
			coords.append(Vector2(x, y))
	return coords

## state_cells ####################################################

# converts the puzzle's raw shape into a list of PuzzleState.Cell
func state_cells() -> Array[PuzzleState.Cell]:
	var cells: Array[PuzzleState.Cell] = []
	for coord in all_coords():
		var obj_name: Variant = shape[coord.y][coord.x]
		if obj_name == null:
			cells.append(PuzzleState.Cell.new(coord, []))
			continue # tho we prolly crashed on the array lookup already
		# after much debate about where to bake in this legend data....
		var objs: Array[DHData.Obj] = DHData.Legend.get_objs(obj_name as String)
		if len(objs) == 0:
			cells.append(PuzzleState.Cell.new(coord, []))
			continue # nothing found in the legend for this
		cells.append(PuzzleState.Cell.new(coord, objs))
	return cells

## rotate ####################################################

func rotate() -> void:
	var new_shape: Array = []
	for row: Array in shape:
		for i: int in len(row):
			if i > len(new_shape) - 1:
				new_shape.append([])
			(new_shape[i] as Array).append(row[i])
	shape = new_shape
	var w: int = width
	var h: int = height
	width = h
	height = w

## log.data() ########################################3333

func data() -> Variant:
	return {meta=meta, idx=idx, is_skipped=is_skipped, is_completed=is_completed,}

## helper ########################################3333

func get_message() -> String:
	if message:
		return message
	else:
		return meta.get("message", "")

## dot count ########################################3333

var _dot_count: int
func dot_count() -> int:
	if _dot_count:
		return _dot_count
	var ct: int = 0
	for x: int in len(shape):
		for y: int in len(shape[x]):
			if shape[x][y] in ["x", "o", "t"]: # NOT IDEAL!
				ct += 1
	_dot_count = ct
	return _dot_count

## shuffle the internal puzzle shape ########################################3333

func shuffle_puzzle_layout(opts: Dictionary = {}) -> void:
	# drop any hangers-on to more easily support consistent puzzle ids/hashes
	# (tho this doesn't cover hand-written transpositions)
	shape = og_shape.duplicate()
	height = og_height
	var reverse_ys: bool = opts.get("reverse_ys", U.rand_of([true, false]))
	var reverse_xs: bool = opts.get("reverse_xs", U.rand_of([true, false]))
	var rotate_shape: bool = opts.get("rotate_shape", U.rand_of([true, false, false, false]))

	var should_add_row: Callable = func() -> bool: return U.rand_of([true, false])

	# adding empty rows
	var new_shape := []
	for row_i: int in len(shape):
		new_shape.append(shape[row_i])
		if should_add_row.call():
			# insert empty row at i
			# TODO do empty rows need to be full width?
			new_shape.append([])
			height += 1
			Log.debug("Adding a random row!")
	# TODO impl for columns via rotate/add_empty_row again?
	# TODO rotate to make this easier
	# new_shape.rotate()
	# for row_i: int in len(shape):
	# 	new_shape.append(shape[row_i])
	# 	if should_add_row.call():
	# 		# insert empty row at i
	# 		# TODO do empty rows need to be full width?
	# 		new_shape.append([])
	shape = new_shape

	if reverse_ys:
		shape.reverse()

	if reverse_xs:
		for row: Array in shape:
			row.reverse()
	if rotate_shape:
		# don't rotate very wide puzzles
		if width <= 6:
			rotate()
