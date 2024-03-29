extends Node

## vars ########################################################3

const STEAM_APP_ID = 2779710
var enabled: bool = false

# Steam variables
var is_on_steam_deck: bool = false
var is_online: bool = false
var is_owned: bool = false
var steam_app_id: int = 480
var steam_id: int = 0
var steam_username: String = ""

var steam

## init ########################################################3

func _init() -> void:
	OS.set_environment("SteamAppId", str(STEAM_APP_ID))
	OS.set_environment("SteamGameId", str(STEAM_APP_ID))

## ready ########################################################3

func _ready():
	if Engine.has_singleton("Steam"):
		steam = Engine.get_singleton("Steam")
	else:
		return

	init_steam()

## process ########################################################3

func _process(_delta):
	if steam:
		steam.run_callbacks()

## init steam ########################################################3

func init_steam() -> void:
	var status = steam.steamInitEx()

	if status.get("status") != 0:
		Log.warn("Steam init failed, disabling steam interactions", status)
		enabled = false
		return

	Log.pr("Steam init success, enabling steam interactions", status)
	enabled = true

	# Gather additional data
	is_on_steam_deck = steam.isSteamRunningOnSteamDeck()
	is_online = steam.loggedOn()
	is_owned = steam.isSubscribed()
	steam_id = steam.getSteamID()
	steam_username = steam.getPersonaName()

	Log.pr("Steam init data", {
			is_on_steam_deck=is_on_steam_deck,
			is_online=is_online,
			is_owned=is_owned,
			steam_id=steam_id,
			steam_username=steam_username,
			})

## achievements ########################################################3

func set_achievement(achv):
	if enabled:
		steam.setAchievement(achv)
		steam.storeStats()

func clear_achievement(achv):
	if enabled:
		steam.clearAchievement(achv)
		steam.storeStats()

func clear_all_achievements():
	if enabled:
		steam.clearAchievement(FIRST_HOP)
		steam.clearAchievement(THEM_DOTS_COMPLETE)
		steam.clearAchievement(SPRING_IN_YOUR_HOP_COMPLETE)
		steam.clearAchievement(THATS_JUST_BEACHY_COMPLETE)
		steam.clearAchievement(LEAF_ME_ALONE_COMPLETE)
		steam.clearAchievement(SNOW_WAY_COMPLETE)
		steam.clearAchievement(GET_OUTER_HERE_COMPLETE)
		steam.clearAchievement(ALL_PUZZLES_COMPLETE)
		steam.clearAchievement(CHEATER_CHEATER_PUMPKIN_EATER)
		steam.clearAchievement(FROM_THE_TOP)
		steam.clearAchievement(TEN_DOTS)
		steam.clearAchievement(FIFTY_DOTS)
		steam.clearAchievement(ONE_HUNDRED_DOTS)
		steam.clearAchievement(TWO_HUNDRED_DOTS)
		steam.clearAchievement(THREE_HUNDRED_DOTS)
		steam.clearAchievement(FOUR_HUNDRED_DOTS)
		steam.clearAchievement(FIVE_HUNDRED_DOTS)
		steam.clearAchievement(SIX_HUNDRED_DOTS)
		steam.clearAchievement(SEVEN_HUNDRED_DOTS)
		steam.clearAchievement(EIGHT_HUNDRED_DOTS)
		steam.clearAchievement(NINE_HUNDRED_DOTS)
		steam.clearAchievement(ONE_THOUSAND_DOTS)
		steam.clearAchievement(ALL_THE_DOTS)
		steam.storeStats()

## game-load achievements

const FIRST_HOP="FIRST_HOP"

func set_first_hop():
	set_achievement(FIRST_HOP)

## puzzle-set-complete achievements

const THEM_DOTS_COMPLETE="THEM_DOTS_COMPLETE"

func set_them_dots_complete():
	set_achievement(THEM_DOTS_COMPLETE)

const SPRING_IN_YOUR_HOP_COMPLETE="SPRING_IN_YOUR_HOP_COMPLETE"

func set_spring_in_your_hop_complete():
	set_achievement(SPRING_IN_YOUR_HOP_COMPLETE)

const THATS_JUST_BEACHY_COMPLETE="THATS_JUST_BEACHY_COMPLETE"

func set_thats_just_beachy_complete():
	set_achievement(THATS_JUST_BEACHY_COMPLETE)

const LEAF_ME_ALONE_COMPLETE="LEAF_ME_ALONE_COMPLETE"

func set_leaf_me_alone_complete():
	set_achievement(LEAF_ME_ALONE_COMPLETE)

const SNOW_WAY_COMPLETE="SNOW_WAY_COMPLETE"

func set_snow_way_complete():
	set_achievement(SNOW_WAY_COMPLETE)

const GET_OUTER_HERE_COMPLETE="GET_OUTER_HERE_COMPLETE"

func set_get_outer_here_complete():
	set_achievement(GET_OUTER_HERE_COMPLETE)

const ALL_PUZZLES_COMPLETE="ALL_PUZZLES_COMPLETE"

func set_all_puzzles_complete():
	set_achievement(ALL_PUZZLES_COMPLETE)

## option-settings achievements

const CHEATER_CHEATER_PUMPKIN_EATER="CHEATER_CHEATER_PUMPKIN_EATER"

func set_cheater_cheater_pumpkin_eater():
	set_achievement(CHEATER_CHEATER_PUMPKIN_EATER)

const FROM_THE_TOP="FROM_THE_TOP"

func set_from_the_top():
	set_achievement(FROM_THE_TOP)

## dot count achievements

const TEN_DOTS="TEN_DOTS"

func set_ten_dots():
	set_achievement(TEN_DOTS)

const FIFTY_DOTS="FIFTY_DOTS"

func set_fifty_dots():
	set_achievement(FIFTY_DOTS)

const ONE_HUNDRED_DOTS="ONE_HUNDRED_DOTS"

func set_one_hundred_dots():
	set_achievement(ONE_HUNDRED_DOTS)

const TWO_HUNDRED_DOTS="TWO_HUNDRED_DOTS"

func set_two_hundred_dots():
	set_achievement(TWO_HUNDRED_DOTS)

const THREE_HUNDRED_DOTS="THREE_HUNDRED_DOTS"

func set_three_hundred_dots():
	set_achievement(THREE_HUNDRED_DOTS)

const FOUR_HUNDRED_DOTS="FOUR_HUNDRED_DOTS"

func set_four_hundred_dots():
	set_achievement(FOUR_HUNDRED_DOTS)

const FIVE_HUNDRED_DOTS="FIVE_HUNDRED_DOTS"

func set_five_hundred_dots():
	set_achievement(FIVE_HUNDRED_DOTS)

const SIX_HUNDRED_DOTS="SIX_HUNDRED_DOTS"

func set_six_hundred_dots():
	set_achievement(SIX_HUNDRED_DOTS)

const SEVEN_HUNDRED_DOTS="SEVEN_HUNDRED_DOTS"

func set_seven_hundred_dots():
	set_achievement(SEVEN_HUNDRED_DOTS)

const EIGHT_HUNDRED_DOTS="EIGHT_HUNDRED_DOTS"

func set_eight_hundred_dots():
	set_achievement(EIGHT_HUNDRED_DOTS)

const NINE_HUNDRED_DOTS="NINE_HUNDRED_DOTS"

func set_nine_hundred_dots():
	set_achievement(NINE_HUNDRED_DOTS)

const ONE_THOUSAND_DOTS="ONE_THOUSAND_DOTS"

func set_one_thousand_dots():
	set_achievement(ONE_THOUSAND_DOTS)

const ALL_THE_DOTS="ALL_THE_DOTS"

func set_all_the_dots():
	set_achievement(ALL_THE_DOTS)
