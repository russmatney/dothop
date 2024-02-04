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

## all properties (consumed by Log.gd) #################

func data():
	return {
		puzzle_scene=get_puzzle_scene(),
		name=get_display_name(),
		is_unlocked=is_unlocked(),
		}

## computed ############################################

## actions ############################################

func unlock():
	set_bool("is_unlocked", true)
