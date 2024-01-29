@tool
extends PandoraEntity
class_name Event

func get_display_name() -> String:
	return get_string("display_name")

func get_timestamp_string() -> String:
	return get_string("timestamp_string")

func get_timestamp_float() -> float:
	return get_float("timestamp_float")

func data():
	return {
		name=get_display_name(),
		}
