@tool
extends VBoxContainer

@onready var mute_music_button = $%MuteMusicButton
@onready var mute_sound_button = $%MuteSoundButton
@onready var mute_all_button = $%MuteAllButton
@onready var unmute_all_button = $%UnmuteAllButton

func _ready():
	render()

	mute_music_button.pressed.connect(func():
		DJ.toggle_mute_music()
		render())
	mute_sound_button.pressed.connect(func():
		DJ.toggle_mute_sound()
		render())
	mute_all_button.pressed.connect(func():
		DJ.mute_all(true)
		render())
	unmute_all_button.pressed.connect(func():
		DJ.mute_all(false)
		render())


func render():
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
