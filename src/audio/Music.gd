@tool
extends Node

# music

@onready var late_night_radio: AudioStream = preload("res://assets/songs/Late Night Radio.mp3")

func _ready() -> void:
	if not Engine.is_editor_hint():
		SoundManager.set_default_music_bus("Music")
		# deferring to give Sounds._ready a chance to set its buses
		# dodging a SoundManager warning about using the Master bus
		SoundManager.set_music_volume.call_deferred(0.3)
