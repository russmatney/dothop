@tool
extends DJSoundMap

###########################################################################
# music

enum M {
	late_night_radio,
	chill_electric_background,
	cool_kids_electronic_bass_groove,
	detective_agency_theme,
	evening_dogs,
	funk_till_five_loop,
	jazz_work,
	}

@onready var music = {
	M.late_night_radio: preload("res://assets/songs/Late Night Radio.mp3"),
	M.chill_electric_background: preload("res://assets/songs/sulosounds/chill-electric-background.wav"),
	M.cool_kids_electronic_bass_groove: preload("res://assets/songs/sulosounds/cool-kids-electronic-bass-groo.wav"),
	M.detective_agency_theme: preload("res://assets/songs/sulosounds/detective-agency-theme.wav"),
	M.evening_dogs: preload("res://assets/songs/sulosounds/evening-dogs.wav"),
	M.funk_till_five_loop: preload("res://assets/songs/sulosounds/funk-till-five-loop.wav"),
	M.jazz_work: preload("res://assets/songs/sulosounds/jazz-work.wav"),
	}

@onready var level_music_tracks = [
	M.chill_electric_background,
	M.cool_kids_electronic_bass_groove,
	M.detective_agency_theme,
	M.evening_dogs,
	M.funk_till_five_loop,
	M.jazz_work,
	]
