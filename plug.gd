extends "res://addons/gd-plug/plug.gd"

func _plugging():
	plug("MikeSchulze/gdUnit4", {exclude=["addons/gdUnit4/test"]})
	plug("bitbrain/pandora", {include=["addons/pandora"]})
	plug("nathanhoad/godot_input_helper", {include=["addons/input_helper"]})
	plug("nathanhoad/godot_sound_manager", {include=["addons/sound_manager"]})
	plug("timothyqiu/gdfxr")
	plug("viniciusgerevini/godot-aseprite-wizard", {include=["addons/AsepriteWizard"]})
	plug("russmatney/log.gd", {include=["addons/log"]})
