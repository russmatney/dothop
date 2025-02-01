@tool
extends VBoxContainer

@onready var mute_music_button: Button = $%MuteMusicButton
@onready var mute_sound_button: Button = $%MuteSoundButton
@onready var mute_all_button: Button = $%MuteAllButton
@onready var unmute_all_button: Button = $%UnmuteAllButton

@onready var music_volume_slider: Slider = $%MusicVolumeSlider
@onready var sound_volume_slider: Slider = $%SoundVolumeSlider

var old_music_volume: float
var old_sound_volume: float

func _ready() -> void:
	if not Engine.is_editor_hint():
		var music_vol := SoundManager.get_music_volume()
		music_volume_slider.set_value(music_vol)

		var sound_vol := SoundManager.get_sound_volume()
		sound_volume_slider.set_value(sound_vol)

	render()

	music_volume_slider.value_changed.connect(func(new_vol: float) -> void:
		SoundManager.set_music_volume(new_vol))

	sound_volume_slider.value_changed.connect(func(new_vol: float) -> void:
		SoundManager.set_sound_volume(new_vol))

	mute_music_button.pressed.connect(mute_music)
	mute_sound_button.pressed.connect(mute_sound)
	mute_all_button.pressed.connect(mute_all)
	unmute_all_button.pressed.connect(unmute_all)

func render() -> void:
	if DJ.muted_music:
		mute_music_button.text = "Unmute Music"
	else:
		mute_music_button.text = "Mute Music"

	if DJ.muted_sound:
		mute_sound_button.text = "Unmute Sound"
	else:
		mute_sound_button.text = "Mute Sound"

	if DJ.muted_music and DJ.muted_sound:
		mute_all_button.hide()
		unmute_all_button.grab_focus()
	else:
		mute_all_button.show()

	if DJ.muted_music or DJ.muted_sound:
		unmute_all_button.show()
	else:
		unmute_all_button.hide()
		mute_all_button.grab_focus()

func update_music_volume() -> void:
	if DJ.muted_music:
		old_music_volume = SoundManager.get_music_volume()
		if old_music_volume < 1:
			old_music_volume = 0.3
		SoundManager.set_music_volume(0)
		music_volume_slider.set_value(0)
	else:
		SoundManager.set_music_volume(old_music_volume)
		music_volume_slider.set_value(old_music_volume)

func update_sound_volume() -> void:
	if DJ.muted_sound:
		old_sound_volume = SoundManager.get_sound_volume()
		if old_sound_volume < 1:
			old_sound_volume = 0.3
		SoundManager.set_sound_volume(0)
		sound_volume_slider.set_value(0)
	else:
		SoundManager.set_sound_volume(old_sound_volume)
		sound_volume_slider.set_value(old_sound_volume)

func mute_music() -> void:
	DJ.toggle_mute_music()
	update_music_volume()
	render()

func mute_sound() -> void:
	DJ.toggle_mute_sound()
	update_sound_volume()
	render()

func mute_all() -> void:
	DJ.mute_all(true)
	update_music_volume()
	update_sound_volume()
	render()

func unmute_all() -> void:
	DJ.mute_all(false)
	update_music_volume()
	update_sound_volume()
	render()
