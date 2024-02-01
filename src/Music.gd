@tool
extends DJSoundMap

###########################################################################
# music

enum M {
	chill_electric_background,
	cool_kids_electronic_bass_groove,
	detective_agency_theme,
	evening_dogs,
	funk_till_five_loop,
	funkmachine_master_loop,
	jazz_work,
	jungle_groove,
	killer_factory_retro_video_game,
	}

@onready var music = {
	M.chill_electric_background: preload("res://assets/songs/sulosounds/chill-electric-background.wav"),
	M.cool_kids_electronic_bass_groove: preload("res://assets/songs/sulosounds/cool-kids-electronic-bass-groo.wav"),
	M.detective_agency_theme: preload("res://assets/songs/sulosounds/detective-agency-theme.wav"),
	M.evening_dogs: preload("res://assets/songs/sulosounds/evening-dogs.wav"),
	M.funk_till_five_loop: preload("res://assets/songs/sulosounds/funk-till-five-loop.wav"),
	M.funkmachine_master_loop: preload("res://assets/songs/sulosounds/funkmachine-master-loop.wav"),
	M.jazz_work: preload("res://assets/songs/sulosounds/jazz-work.wav"),
	M.jungle_groove: preload("res://assets/songs/sulosounds/jungle-groove.wav"),
	M.killer_factory_retro_video_game: preload("res://assets/songs/sulosounds/killer-fatory-retro-video-game.wav"),
	}

@onready var level_music_tracks = [
	music[M.chill_electric_background],
	music[M.cool_kids_electronic_bass_groove],
	music[M.detective_agency_theme],
	music[M.evening_dogs],
	music[M.funk_till_five_loop],
	music[M.funkmachine_master_loop],
	music[M.jazz_work],
	music[M.jungle_groove],
	music[M.killer_factory_retro_video_game],
	]
