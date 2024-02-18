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

# TODO analysis data/type
var analysis: Dictionary


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
	return {obj=str(self), meta=meta, width=width, height=height, idx=idx}
