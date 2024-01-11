@tool
extends Node

## is this window focused?
# https://docs.godotengine.org/en/stable/tutorials/inputs/controllers_gamepads_joysticks.html#window-focus
# TODO move this state to some other node so this can be just controls
var focused := true

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			focused = false
		NOTIFICATION_APPLICATION_FOCUS_IN:
			focused = true

## simulate ################################################################

func sim_action_pressed(action, release_after=null, released=null):
	var evt = InputEventAction.new()
	evt.action = action
	evt.pressed = true
	Input.parse_input_event(evt)
	if release_after != null:
		await get_tree().create_timer(release_after).timeout
		sim_action_released.call_deferred(action)
		if released != null:
			released.emit()

func sim_action_released(action):
	var evt = InputEventAction.new()
	evt.action = action
	evt.pressed = false
	Input.parse_input_event(evt)

func close():
	sim_action_pressed("close", 0.2)

func attack(t=0.5):
	if t:
		sim_action_pressed("attack", t)
	else:
		sim_action_pressed("attack")

func sim_move(dir: Vector2, release_after=0.8, released=null):
	match dir:
		Vector2.LEFT: sim_action_pressed("move_left", release_after, released)
		Vector2.RIGHT: sim_action_pressed("move_right", release_after, released)
		Vector2.UP: sim_action_pressed("move_up", release_after, released)
		Vector2.DOWN: sim_action_pressed("move_down", release_after, released)
		_: Log.warn("Not-impled: simulated input in non-cardinal directions", dir)


## public #################################################################

func is_event(event, event_name):
	if focused:
		return event.is_action_pressed(event_name)
	return false

func is_pressed(event, event_name):
	return is_event(event, event_name)

func is_held(event, event_name):
	return is_event(event, event_name)

func is_released(event, event_name):
	if focused:
		return event.is_action_released(event_name)
	return false


# returns a normalized Vector2 based checked the controller's movement
func move_vector():
	if focused:
		return Input.get_vector("move_left", "move_right", "move_up", "move_down")
	return Vector2.ZERO

func grid_move_vector(thresh=0.6):
	var move = move_vector()
	if move.x > thresh:
		return Vector2.RIGHT
	elif move.x < -1*thresh:
		return Vector2.LEFT
	elif move.y < -1*thresh:
		return Vector2.UP
	elif move.y > thresh:
		return Vector2.DOWN
	return Vector2.ZERO

func is_move(event):
	return is_event(event, "move_left") or is_event(event, "move_right") or \
		is_event(event, "move_up") or is_event(event, "move_down")

func is_move_released(event):
	return is_released(event, "move_left") or is_released(event, "move_right") or \
		is_released(event, "move_up") or is_released(event, "move_down")

func is_move_up(event):
	return is_event(event, "move_up")

func is_move_down(event):
	return is_event(event, "move_down")

func is_restart(event):
	return is_event(event, "restart")

func is_restart_held(event):
	return is_held(event, "restart")

func is_restart_released(event):
	return is_released(event, "restart")

func is_undo(event):
	return is_event(event, "undo")

func is_fire(event):
	return is_event(event, "fire")

func is_fire_released(event):
	return is_released(event, "fire")

func is_jump(event):
	return is_event(event, "jump")

func is_dash(event):
	return is_event(event, "dash")

func is_jetpack(event):
	return is_event(event, "jetpack")

func is_attack(event):
	return is_event(event, "attack")

func is_attack_released(event):
	return is_released(event, "attack")

func is_action(event):
	return is_event(event, "action")

func is_cycle_next_action(event):
	return is_event(event, "cycle_next_action")

func is_cycle_prev_action(event):
	return is_event(event, "cycle_previous_action")

func is_pause(event):
	return is_event(event, "pause")

func is_close(event):
	return is_event(event, "close")

func is_debug_toggle(event):
	return is_event(event, "debug_toggle")
