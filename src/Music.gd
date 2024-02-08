@tool
extends Node

# music

@onready var late_night_radio = preload("res://assets/songs/Late Night Radio.mp3")
@onready var chill_electric_background = preload("res://assets/songs/sulosounds/chill-electric-background.wav")
@onready var cool_kids_electronic_bass_groove = preload("res://assets/songs/sulosounds/cool-kids-electronic-bass-groo.wav")
@onready var detective_agency_theme = preload("res://assets/songs/sulosounds/detective-agency-theme.wav")
@onready var evening_dogs = preload("res://assets/songs/sulosounds/evening-dogs.wav")
@onready var funk_till_five_loop = preload("res://assets/songs/sulosounds/funk-till-five-loop.wav")
@onready var jazz_work = preload("res://assets/songs/sulosounds/jazz-work.wav")

func _ready():
	if not Engine.is_editor_hint():
		SoundManager.set_default_music_bus("Music")
		SoundManager.set_music_volume(0.7)
