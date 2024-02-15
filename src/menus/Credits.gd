@tool
extends Credits

var dothop_credits = [
	[
		"",
		"",
		"# Dot Hop",
		"",
	], [
		"by Russell Matney",
	], [
		"",
		"",
		"Made with Godot, Aseprite, and Emacs",
		"",
		"",
	],
    [
	"",
	"# Music",
	], [
	"",
	"Late Night Radio",
	"by Kevin MacLeod (incompetech.com)",
	"Licensed under Creative Commons: By Attribution 4.0 License",
	"http://creativecommons.org/licenses/by/4.0",
	"MIT License",
	"",
	"chill-electric-background",
	"cool-kids-electronic-bass-groove",
	"detective-agency-theme",
	"funk-till-five-loop",
	"funkmachine-master-loop",
	"jazz-work",
	"jungle-groove",
	"killer-factory-retro-video-game",
	"All by SuloSounds",
	"https://sulosounds.itch.io/100-songs",
	"CC0 - Public Domain",
	"https://creativecommons.org/share-your-work/public-domain/cc0/",
	"",
	],
    [
	"",
	"# Sounds",
	], [
	"",
	"retro game weapon sound effects",
	"happysoulmusic.com",
	"https://happysoulmusic.com/retro-game-weapons-sound-effects/",
	"cc0",
	"https://creativecommons.org/publicdomain/zero/1.0/",
	"",
	"",
	"Most sounds generated via gdfxr (a godot sfxr addon)",
	"https://github.com/timothyqiu/gdfxr",
	"",
	],
    [
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
	"https://grafxkid.itch.io/at01",
	"Public Domain",
	"https://creativecommons.org/publicdomain/zero/1.0/",
	"",
	"Adventurer",
	"by Brain J Smith",
	"http://www.pentacom.jp/pentacom/bitfontmaker2/gallery/?id=195",
	"Creative Commons Attribution",
	"",
	],
    [
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
	],
    [
	"",
	"# Art",
	], [
	"",
	"Treasure Hunters (Wood + Paper Panel UI)",
	"By Pixel Frog",
	"https://pixelfrog-assets.itch.io/treasure-hunters",
	"Public Domain",
	"https://creativecommons.org/publicdomain/zero/1.0/",
	"",
	"Input Prompts",
	"Kenney.nl",
	"https://www.kenney.nl/assets/input-prompts",
	"Public Domain",
	"https://creativecommons.org/publicdomain/zero/1.0/",
	"",
	],
    [
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
	],
    [
	"",
	"# Other",
	], [
	"",
	"All other art, music, and sounds created by Russell Matney",
	"",
	],
    [
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
	],
    [
	"",
	"# Testers",
	], [
	"",
	"tompsognathus",
	"",
	"",
	"Many thanks to all the testers and brainstormers who listened and gave feedback!",
	"",
	"",
	], [
	"",
	"# Thank you for playing!",
	"",
	"",
	],
]

func get_credit_lines():
	return dothop_credits

## vars #################################################

@onready var main_menu_button = $%MainMenuButton

## ready #################################################

func _ready():
	if not Engine.is_editor_hint():
		SoundManager.play_music(Music.late_night_radio)

	super._ready()
	main_menu_button.pressed.connect(func():
		Navi.nav_to_main_menu())
	main_menu_button.grab_focus.call_deferred()
	main_menu_button.visibility_changed.connect(func():
		main_menu_button.grab_focus())
