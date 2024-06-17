@tool
extends Node
class_name Trolls

## public #################################################################

static func is_event(event, event_name):
	if Dino.focused:
		return event.is_action_pressed(event_name)
	return false

static func is_pressed(event, event_name):
	return is_event(event, event_name)

static func is_held(event, event_name):
	return is_event(event, event_name)

static func is_released(event, event_name):
	if Dino.focused:
		return event.is_action_released(event_name)
	return false

static func is_screen_drag_event(event):
	if event is InputEventScreenDrag:
		return (
			(abs(event.relative.x) > 4 or abs(event.relative.y) > 4)
			and
			(abs(event.velocity.x) > 100 or abs(event.velocity.y) > 100))

# returns a normalized Vector2 based checked the controller's movement
static func move_vector(event=null):
	if event:
		if Trolls.is_screen_drag_event(event):
			var dir = to_cardinal_direction(event.velocity, 100)
			Log.pr("drag gesture dir", dir)
			return dir
	if Dino.focused:
		return Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	return Vector2.ZERO

static func to_cardinal_direction(vec, thresh=0.6):
	if vec.x > thresh:
		return Vector2.RIGHT
	elif vec.x < -1*thresh:
		return Vector2.LEFT
	elif vec.y < -1*thresh:
		return Vector2.UP
	elif vec.y > thresh:
		return Vector2.DOWN
	return Vector2.ZERO

static func grid_move_vector(event=null, thresh=0.6):
	var move = move_vector(event)
	return Trolls.to_cardinal_direction(move, thresh)

static func is_move(event):
	return (is_event(event, "ui_left") or
		is_event(event, "ui_right") or
		is_event(event, "ui_up") or
		is_event(event, "ui_down") or
		is_screen_drag_event(event))

static func is_move_released(event):
	return is_released(event, "ui_left") or is_released(event, "ui_right") or \
		is_released(event, "ui_up") or is_released(event, "ui_down")

static func is_move_up(event):
	return is_event(event, "ui_up")

static func is_move_down(event):
	return is_event(event, "ui_down")

static func is_move_left(event):
	return is_event(event, "ui_left")

static func is_move_right(event):
	return is_event(event, "ui_right")

static func is_restart(event):
	return is_event(event, "restart")

static func is_restart_held(event):
	return is_held(event, "restart")

static func is_restart_released(event):
	return is_released(event, "restart")

static func is_undo(event):
	return is_event(event, "ui_undo")

static func is_accept(event):
	return is_event(event, "ui_accept")

static func is_pause(event):
	return is_event(event, "pause")

static func is_close(event):
	return is_event(event, "close")

static func is_close_released(event):
	return is_released(event, "close")

static func is_debug_toggle(event):
	return is_event(event, "debug_toggle")
