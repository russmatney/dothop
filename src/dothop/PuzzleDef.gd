@tool
extends Object
class_name PuzzleDef

# helpful for supporting some tests
static func parse(lines: Array) -> PuzzleDef:
	return PuzzleDef.new(ParsedGame.new().parse_puzzle(lines) as Dictionary)

## vars ########################################3333

var shape: Array
var width: int
var height: int
var idx: int
var meta: Dictionary
var message: String

var analysis: PuzzleAnalysis

var is_completed: bool
var is_skipped: bool

## init ########################################3333

func _init(raw: Dictionary) -> void:
	if raw.shape:
		shape = raw.shape
	width = raw.width
	height = raw.height
	meta = raw.meta
	if "message" in raw:
		message = raw.message
	if "idx" in raw:
		idx = raw.idx

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
	var reverse_ys: bool = opts.get("reverse_ys", U.rand_of([true, false]))
	var reverse_xs: bool = opts.get("reverse_xs", U.rand_of([true, false]))
	var rotate_shape: bool = opts.get("rotate_shape", U.rand_of([true, false, false, false]))

	if reverse_ys:
		shape.reverse()
	if reverse_xs:
		for row: Array in shape:
			row.reverse()
	if rotate_shape:
		# don't rotate very wide puzzles
		if width <= 6:
			rotate()
