extends "res://addons/gd-plug/plug.gd"

func _plugging() -> void:
	plug("MikeSchulze/gdUnit4", {exclude=["addons/gdUnit4/test"]})
	plug("bitbrain/pandora", {include=["addons/pandora"]})
	plug("nathanhoad/godot_input_helper", {include=["addons/input_helper"]})
	plug("nathanhoad/godot_sound_manager", {include=["addons/sound_manager"]})
	plug("timothyqiu/gdfxr", {branch="godot-4"})
	plug("viniciusgerevini/godot-aseprite-wizard", {include=["addons/AsepriteWizard"]})
	plug("russmatney/log.gd", {include=["addons/log"]})
	plug("russmatney/bones", {include=[
		"addons/bones", "assets/kenney-input-prompts"
		]})
	plug("ramokz/phantom-camera", {include=["addons/phantom_camera"]})
