@tool
extends Node

# music

@onready var late_night_radio = preload("res://assets/songs/Late Night Radio.mp3")

func _ready():
	if not Engine.is_editor_hint():
		SoundManager.set_default_music_bus("Music")
		SoundManager.set_music_volume(0.3)
