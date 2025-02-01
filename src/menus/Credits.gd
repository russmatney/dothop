@tool
extends Credits

var dothop_credits := [
	[
		"",
		"",
		"# [color=crimson]Dot Hop[/color]",
		"",
	], [
		"# by [color=forest_green]Russell Matney[/color]",
	], [
		"",
		"",
		"Made with Godot, Aseprite, and Emacs",
		"",
		"Source available: https://github.com/russmatney/dothop",
	], [
	"",
	"# Music",
	], [
	"",
	"Late Night Radio",
	"by Kevin MacLeod (incompetech.com)",
	"Licensed under Creative Commons: By Attribution 4.0 License",
	"http://creativecommons.org/licenses/by/4.0",
	"",
	"",
	"Giving Up",
	"Is this Mood",
	"Lounge Groove",
	"Verdant Grove",
	"by Ben Burnes - Abstraction",
	"Licensed under Creative Commons: By Attribution 4.0 License",
	"http://creativecommons.org/licenses/by/4.0",
	"",
	"",
	"chill-electric-background",
	"funk-till-five-loop",
	"by SuloSounds",
	# "https://sulosounds.itch.io/100-songs",
	"CC0 - Public Domain",
	"https://creativecommons.org/share-your-work/public-domain/cc0/",
	"",
	], [
	"",
	"# Sounds",
	], [
	"",
	"",
	"retro game weapon sound effects",
	"happysoulmusic.com",
	"https://happysoulmusic.com/retro-game-weapons-sound-effects/",
	"cc0",
	"https://creativecommons.org/publicdomain/zero/1.0/",
	"",
	"",
	"Growler Music",
	"https://freesound.org/people/GowlerMusic/sounds/266566/",
	"",
	"",
	"Most sounds generated via gdfxr (a godot sfxr addon)",
	"https://github.com/timothyqiu/gdfxr",
	"",
	], [
	"",
	"# Fonts",
	], [
	"",
	"born2bsportyv2",
	"by japanyoshi",
	"http://www.pentacom.jp/pentacom/bitfontmaker2/gallery/?id=383",
	"Public Domain",
	"https://creativecommons.org/publicdomain/zero/1.0/",
	"",
	"at10",
	"by grafxkid",
	# "https://grafxkid.itch.io/at01",
	"Public Domain",
	"https://creativecommons.org/publicdomain/zero/1.0/",
	"",
	"Adventurer",
	"by Brain J Smith",
	"http://www.pentacom.jp/pentacom/bitfontmaker2/gallery/?id=195",
	"Creative Commons Attribution",
	"",
	], [
	"",
	"# Color Palettes",
	], [
	"",
	"lospec 500",
	"A collaboration, including Foxbutt, Rhoq, Dimi, Skeddles, MiggityMoogity,
	PureAsbestos, Polyducks, SybilQ, Unsettled, DaaWeed, Moertel, KingW, Glacier,
	WildLeoKnight and GooGroker",
	"https://lospec.com/palette-list/lospec500",
	"",
	"autumn glow",
	"by sonnenstein",
	"https://lospec.com/palette-list/autumn-glow",
	"",
	], [
	"",
	"# Art",
	], [
	"",
	"Treasure Hunters (Wood + Paper Panel UI)",
	"By Pixel Frog",
	# "https://pixelfrog-assets.itch.io/treasure-hunters",
	"Public Domain",
	"https://creativecommons.org/publicdomain/zero/1.0/",
	"",
	"Input Prompts",
	"Kenney.nl",
	"https://www.kenney.nl/assets/input-prompts",
	"Public Domain",
	"https://creativecommons.org/publicdomain/zero/1.0/",
	"",
	], [
	"",
	"# Godot Addons",
	], [
	"",
	"AsepriteWizard",
	"https://github.com/viniciusgerevini/godot-aseprite-wizard",
	"MIT License",
	"",
	"gdfxr",
	"https://github.com/timothyqiu/gdfxr",
	"MIT License",
	"",
	"GDUnit4",
	"https://github.com/MikeSchulze/gdUnit4",
	"MIT License",
	"",
	"Input Helper",
	"https://github.com/nathanhoad/godot_input_helper",
	"MIT License",
	"",
	"Pandora",
	"https://github.com/bitbrain/pandora",
	"MIT License",
	"",
	"Sound Manager",
	"https://github.com/nathanhoad/godot_sound_manager",
	"MIT License",
	"",
	"GodotSteam",
	"https://github.com/CoaguCo-Industries/GodotSteam",
	"MIT License",
	"",
	], [
	"",
	"# Other",
	], [
	"",
	"All other art, music, and sounds created by Russell Matney",
	"",
	], [
	"# Patrons",
	], [
	"",
	"Cameron Kingsbury",
	"Duaa Osman",
	"Ryan Schmukler",
	"Alex Chojnacki",
	"Aspen Smith",
	"Jake Bartlam",
	"Ellie Matney",
	"",
	], [
	"",
	"# Play Testers",
	], [
	"",
	"Duaa Osman",
	"tompsognathus",
	"Cameron Kingsbury",
	"Nicole Pavia",
	# "Trey Budnick",
	"Ryan Schmukler",
	"Aspen Smith",
	"Eliana Abraham",
	"Josh Skrzypek",
	"Jake Bartlam",
	"Brooke Matney",
	"Ryan Matney",
	"Ellie Matney",
	"Kevin Goldfield",
	"Istvan",
	"Rick Williams",
	"juk3n",
	"Ashley Zingillioglu",
	"Torin Denniston",
	"A bunch of folks at Strangeloop",
	"The IGA check-in/show-and-tell crew",
	"",
	], [
	"",
	"# Special Thanks",
	], [
	"",
	"For constant support and feedback across DotHop's entire developement,",
	"and for happily playing the game in all its forms,",
	"both with and without my constant nagging.",
	"",
	"Duaa Osman",
	"tompsognathus",
	"Cameron Kingsbury",
	"",
	"Thank you all so freaking much!",
	"",
	], [
	"",
	"# Thank you for playing!",
	"",
	"",
	],
]

func get_credit_lines() -> Array:
	return dothop_credits

## vars #################################################

@onready var main_menu_button: Button = $%MainMenuButton

## ready #################################################

func _ready() -> void:
	if not Engine.is_editor_hint():
		SoundManager.play_music(Music.late_night_radio)

	super._ready()
	main_menu_button.pressed.connect(func() -> void:
		Navi.nav_to_main_menu())
	main_menu_button.grab_focus.call_deferred()
	main_menu_button.visibility_changed.connect(func() -> void:
		main_menu_button.grab_focus())
