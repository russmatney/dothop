@tool
extends PandoraEntity
class_name DHTheme

## properties ##########################################

func get_puzzle_scene() -> PackedScene:
	return get_resource("puzzle_scene")

func get_display_name() -> String:
	return get_string("display_name")

func is_unlocked() -> bool:
	return get_bool("is_unlocked")

func get_player_scenes() -> Array[PackedScene]:
	var arr = get_array("player_scenes")
	var ar: Array[PackedScene] = []
	for a in arr:
		var sc = load(a)
		ar.append(sc)
	return ar

func get_dot_scenes() -> Array[PackedScene]:
	var arr = get_array("dot_scenes")
	var ar: Array[PackedScene] = []
	for a in arr:
		ar.append(load(a))
	return ar

func get_goal_scenes() -> Array[PackedScene]:
	var arr = get_array("goal_scenes")
	var ar: Array[PackedScene] = []
	for a in arr:
		ar.append(load(a))
	return ar

## all properties (consumed by Log.gd) #################

func data():
	return {
		puzzle_scene=get_puzzle_scene(),
		name=get_display_name(),
		is_unlocked=is_unlocked(),
		player_scenes=len(get_player_scenes()),
		dot_scenes=len(get_dot_scenes()),
		goal_scenes=len(get_goal_scenes()),
		}

## computed ############################################

## actions ############################################

func unlock():
	set_bool("is_unlocked", true)
