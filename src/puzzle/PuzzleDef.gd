@tool
extends Object
class_name PuzzleDef

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

func _init(raw: Dictionary):
	if raw.shape:
		shape = raw.shape
	width = raw.width
	height = raw.height
	meta = raw.meta
	if "message" in raw:
		message = raw.message
	if "idx" in raw:
		idx = raw.idx

## log.data() ########################################3333

func data():
	return {meta=meta, idx=idx, is_skipped=is_skipped, is_completed=is_completed,}

## helper ########################################3333

func get_message():
	if message:
		return message
	else:
		return meta.get("message")

## dot count ########################################3333

var _dot_count
func dot_count():
	if _dot_count:
		return _dot_count
	var ct = 0
	for x in len(shape):
		for y in len(shape[x]):
			if shape[x][y] in ["x", "o", "t"]: # NOT IDEAL!
				ct += 1
	_dot_count = ct
	return _dot_count
