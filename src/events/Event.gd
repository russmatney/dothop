@tool
extends PandoraEntity
class_name Event

func get_display_name() -> String:
	return get_string("display_name")

func get_timestamp_string() -> String:
	return get_string("timestamp_string")

func get_timestamp_float() -> float:
	return get_float("timestamp_float")

func get_count() -> int:
	return get_integer("count")

func data():
	return {
		name=get_display_name(),
		time=get_timestamp_string(),
		count=get_count(),
		}

func set_event_data(opts: Dictionary):
	var name = opts.get("display_name")
	if name:
		set_string("display_name", name)

	var now_str = Time.get_datetime_string_from_system()
	var now_float = Time.get_unix_time_from_system()
	set_string("timestamp_string", now_str)
	set_float("timestamp_float", now_float)

func inc_count():
	set_integer("count", get_count() + 1)
