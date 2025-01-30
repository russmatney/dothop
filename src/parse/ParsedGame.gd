@tool
extends Object
class_name ParsedGame

var section_parsers: Dictionary = {
	"prelude": parse_prelude,
	"objects": parse_objects,
	"legend": parse_legend,
	"sounds": parse_sounds,
	"collisionlayers": parse_collision_layers,
	"rules": parse_rules,
	"winconditions": parse_win_conditions,
	"puzzles": parse_puzzles,
	}

# TODO create a stronger type for this (ParsedGame? duh?)
func parse(contents: String) -> Dictionary:
	var parsed: Dictionary = {}

	# force a similar prelude header
	contents = "=======\nPRELUDE\n=======\n\n" + contents
	var raw_sections = contents.split("\n\n=")
	for raw_s in raw_sections:
		var chunks = raw_s.split("\n\n")
		var header = chunks[0].split("\n")
		chunks.remove_at(0)
		header = header[1] # middle line
		var parser = section_parsers.get(header.to_lower())
		if parser:
			chunks = Array(chunks).map(func(c): return c.split("\n"))
			chunks = chunks.map(func(chunk):
				return Array(chunk).filter(func(c):
					return c != "" and c != "\t" and c != "\t\t" and c != "\t\t\t")
				).filter(func(chunk): return len(chunk) > 0)
			parsed[header.to_lower()] = parser.call(chunks)
	return parsed

func parse_metadata(lines):
	var data = {}
	for l in lines:
		if l == "":
			continue
		var parts = l.split(" ", false, 1)
		var key = parts[0]
		parts.remove_at(0)
		var val = true
		if parts.size() > 0:
			val = " ".join(parts)
		data[key] = val
	return data

## prelude #########################################################

func parse_prelude(chunks):
	var lines = chunks.reduce(func(acc, x):
		acc.append_array(x)
		# fking update-in-place with no return bs
		return acc, [])
	var prelude = {}
	for l in lines:
		if l == "":
			continue
		var parts = l.split(" ", false, 1)
		var key = parts[0]
		parts.remove_at(0)
		var val = true
		if parts.size() > 0:
			val = " ".join(parts)
		prelude[key] = val
	return prelude

## objects #########################################################

func parse_objects(chunks):
	var objs = {}
	for lines in chunks:
		var obj = {}
		var nm_parts = lines[0].split(" ")
		obj.name = nm_parts[0]
		if nm_parts.size() > 1:
			obj.symbol = nm_parts[1]
		obj.colors = Array(lines[1].split(" "))
		if lines.size() > 2:
			lines.remove_at(0)
			lines.remove_at(0)
			obj.shape = parse_shape(lines, true)

		objs[obj.name] = obj

	return objs

func parse_shape(lines, parse_int=false):
	var shape = []
	for l in lines:
		var row = []
		for c in l:
			if c == ".":
				row.append(null)
			elif parse_int:
				row.append(int(c))
			else:
				row.append(c)
		if row.size() > 0:
			shape.append(row)
	return shape

## legend #########################################################

func parse_legend(chunks):
	var legend = {}
	for lines in chunks:
		for l in lines:
			var parts = l.split(" = ")
			# support 'or' ?
			var val_parts = parts[1].split(" and ")
			legend[parts[0]] = Array(val_parts)

	return legend

## sounds #########################################################

func parse_sounds(chunks):
	var sounds = []
	for lines in chunks:
		for l in lines:
			var parts = l.split(" ")
			sounds.append(Array(parts))
	return sounds

## collision_layers #########################################################

func parse_collision_layers(chunks):
	var layers = []
	for lines in chunks:
		for l in lines:
			var parts = l.split(", ")
			layers.append(Array(parts))
	return layers

## rules #########################################################

func parse_rules(chunks):
	var rules = []
	for lines in chunks:
		for l in lines:
			var parts = l.split(" -> ")
			var new_rule = {pattern=parse_pattern(parts[0])}
			if len(parts) > 1:
				new_rule["update"] = parse_pattern(parts[1])
			rules.append(new_rule)
	return rules

func parse_pattern(rule_pattern_str):
	var initial_terms = []
	# initial terms
	if not rule_pattern_str.begins_with("["):
		var parts = rule_pattern_str.split(" ")
		for p in parts:
			if p.begins_with("["):
				break
			else:
				initial_terms.append(p)

	# parse between the brackets
	var regex = RegEx.new()
	regex.compile("\\[\\s*(.*)\\s*\\]")
	var res = regex.search(rule_pattern_str)

	if res == null:
		return initial_terms

	var inner = res.get_string(1)

	var inner_cells = inner.split(" | ")
	var cells = []
	for c in inner_cells:
		var parts = c.split(" ")
		var cell = []
		for p in parts:
			if len(p) > 0:
				cell.append(p)
		cells.append(cell)

	var pattern = []
	pattern.append_array(initial_terms)
	pattern.append_array(cells)
	return pattern

## win_conditions #########################################################

func parse_win_conditions(chunks):
	var conds = []
	for lines in chunks:
		for l in lines:
			var parts = l.split(" ")
			conds.append(Array(parts))
	return conds

## puzzles #########################################################

func parse_puzzle(shape_lines: Array, raw_meta: Array = []) -> Dictionary:
	var meta = parse_metadata(raw_meta)
	var raw_shape
	if shape_lines:
		raw_shape = parse_shape(shape_lines)
	var line_count: int = 0
	if shape_lines:
		line_count = len(shape_lines)

	var puzzle = {
		meta=meta,
		shape=raw_shape,
		height=line_count,
		}

	if line_count > 0:
		puzzle["width"] = len(shape_lines[0])
	else:
		puzzle["width"] = 0
	# maybe want to optimize away from this?
	return puzzle.duplicate(true)

func parse_puzzles(chunks):
	var puzzles = []
	var skip = false
	for i in len(chunks):
		if skip:
			skip = false
			continue
		# NOTE this is precarious and weird!!
		if chunks[i][0][0] in [".", "#", "a", "b", "o", "t", "x", "y"]:
			puzzles.append(parse_puzzle(chunks[i]))
			skip = false
		else:
			var raw_meta = chunks[i]
			var shape_lines
			if i + 1 < len(chunks):
				shape_lines = chunks[i+1]
			puzzles.append(parse_puzzle(shape_lines, raw_meta))
			skip = true
	for i in len(puzzles):
		puzzles[i].idx = i
	return puzzles
