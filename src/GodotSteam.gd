extends Node

## vars ########################################################3

const STEAM_APP_ID: int = 2779710
var enabled: bool = false

# Steam variables
var is_on_steam_deck: bool = false
var is_online: bool = false
var is_owned: bool = false
var steam_app_id: int = 480
var steam_id: int = 0
var steam_username: String = ""

var steam: Variant

## init ########################################################3

func _init() -> void:
	OS.set_environment("SteamAppId", str(STEAM_APP_ID))
	OS.set_environment("SteamGameId", str(STEAM_APP_ID))

## ready ########################################################3

func _ready() -> void:
	if Engine.has_singleton("Steam"):
		steam = Engine.get_singleton("Steam")
	else:
		return

	init_steam()

## process ########################################################3

func _process(_delta: float) -> void:
	if steam:
		@warning_ignore("unsafe_method_access")
		steam.run_callbacks()

## init steam ########################################################3

func init_steam() -> void:
	@warning_ignore("unsafe_method_access")
	var status: Variant = steam.steamInitEx()

	@warning_ignore("unsafe_method_access")
	if status.get("status") != 0:
		Log.warn("Steam init failed, disabling steam interactions", status)
		enabled = false
		return

	Log.pr("Steam init success, enabling steam interactions", status)
	enabled = true

	# Gather additional data
	@warning_ignore("unsafe_method_access")
	is_on_steam_deck = steam.isSteamRunningOnSteamDeck()
	@warning_ignore("unsafe_method_access")
	is_online = steam.loggedOn()
	@warning_ignore("unsafe_method_access")
	is_owned = steam.isSubscribed()
	@warning_ignore("unsafe_method_access")
	steam_id = steam.getSteamID()
	@warning_ignore("unsafe_method_access")
	steam_username = steam.getPersonaName()

	Log.pr("Steam init data", {
			is_on_steam_deck=is_on_steam_deck,
			is_online=is_online,
			is_owned=is_owned,
			steam_id=steam_id,
			steam_username=steam_username,
			})

## achievements ########################################################3

func set_achievement(achv: String) -> void:
	if enabled:
		@warning_ignore("unsafe_method_access")
		steam.setAchievement(achv)
		@warning_ignore("unsafe_method_access")
		steam.storeStats()

func clear_achievement(achv: String) -> void:
	if enabled:
		@warning_ignore("unsafe_method_access")
		steam.clearAchievement(achv)
		@warning_ignore("unsafe_method_access")
		steam.storeStats()

func clear_all_achievements() -> void:
	if enabled:
		@warning_ignore("unsafe_method_access")
		steam.clearAchievement(FIRST_HOP)
		@warning_ignore("unsafe_method_access")
		steam.clearAchievement(THEM_DOTS_COMPLETE)
		@warning_ignore("unsafe_method_access")
		steam.clearAchievement(SPRING_IN_YOUR_HOP_COMPLETE)
		@warning_ignore("unsafe_method_access")
		steam.clearAchievement(THATS_JUST_BEACHY_COMPLETE)
		@warning_ignore("unsafe_method_access")
		steam.clearAchievement(LEAF_ME_ALONE_COMPLETE)
		@warning_ignore("unsafe_method_access")
		steam.clearAchievement(SNOW_WAY_COMPLETE)
		@warning_ignore("unsafe_method_access")
		steam.clearAchievement(GET_OUTER_HERE_COMPLETE)
		@warning_ignore("unsafe_method_access")
		steam.clearAchievement(ALL_PUZZLES_COMPLETE)
		@warning_ignore("unsafe_method_access")
		steam.clearAchievement(CHEATER_CHEATER_PUMPKIN_EATER)
		@warning_ignore("unsafe_method_access")
		steam.clearAchievement(FROM_THE_TOP)
		@warning_ignore("unsafe_method_access")
		steam.clearAchievement(TEN_DOTS)
		@warning_ignore("unsafe_method_access")
		steam.clearAchievement(FIFTY_DOTS)
		@warning_ignore("unsafe_method_access")
		steam.clearAchievement(ONE_HUNDRED_DOTS)
		@warning_ignore("unsafe_method_access")
		steam.clearAchievement(TWO_HUNDRED_DOTS)
		@warning_ignore("unsafe_method_access")
		steam.clearAchievement(THREE_HUNDRED_DOTS)
		@warning_ignore("unsafe_method_access")
		steam.clearAchievement(FOUR_HUNDRED_DOTS)
		@warning_ignore("unsafe_method_access")
		steam.clearAchievement(FIVE_HUNDRED_DOTS)
		@warning_ignore("unsafe_method_access")
		steam.clearAchievement(SIX_HUNDRED_DOTS)
		@warning_ignore("unsafe_method_access")
		steam.clearAchievement(SEVEN_HUNDRED_DOTS)
		@warning_ignore("unsafe_method_access")
		steam.clearAchievement(EIGHT_HUNDRED_DOTS)
		@warning_ignore("unsafe_method_access")
		steam.clearAchievement(NINE_HUNDRED_DOTS)
		@warning_ignore("unsafe_method_access")
		steam.clearAchievement(ONE_THOUSAND_DOTS)
		@warning_ignore("unsafe_method_access")
		steam.clearAchievement(ALL_THE_DOTS)
		@warning_ignore("unsafe_method_access")
		steam.storeStats()

## game-load achievements

const FIRST_HOP: String = "FIRST_HOP"

func set_first_hop() -> void:
	set_achievement(FIRST_HOP)

## puzzle-set-complete achievements

const THEM_DOTS_COMPLETE: String = "THEM_DOTS_COMPLETE"

func set_them_dots_complete() -> void:
	set_achievement(THEM_DOTS_COMPLETE)

const SPRING_IN_YOUR_HOP_COMPLETE: String = "SPRING_IN_YOUR_HOP_COMPLETE"

func set_spring_in_your_hop_complete() -> void:
	set_achievement(SPRING_IN_YOUR_HOP_COMPLETE)

const THATS_JUST_BEACHY_COMPLETE: String = "THATS_JUST_BEACHY_COMPLETE"

func set_thats_just_beachy_complete() -> void:
	set_achievement(THATS_JUST_BEACHY_COMPLETE)

const LEAF_ME_ALONE_COMPLETE: String = "LEAF_ME_ALONE_COMPLETE"

func set_leaf_me_alone_complete() -> void:
	set_achievement(LEAF_ME_ALONE_COMPLETE)

const SNOW_WAY_COMPLETE: String = "SNOW_WAY_COMPLETE"

func set_snow_way_complete() -> void:
	set_achievement(SNOW_WAY_COMPLETE)

const GET_OUTER_HERE_COMPLETE: String = "GET_OUTER_HERE_COMPLETE"

func set_get_outer_here_complete() -> void:
	set_achievement(GET_OUTER_HERE_COMPLETE)

const ALL_PUZZLES_COMPLETE: String = "ALL_PUZZLES_COMPLETE"

func set_all_puzzles_complete() -> void:
	set_achievement(ALL_PUZZLES_COMPLETE)

## option-settings achievements

const CHEATER_CHEATER_PUMPKIN_EATER: String = "CHEATER_CHEATER_PUMPKIN_EATER"

func set_cheater_cheater_pumpkin_eater() -> void:
	set_achievement(CHEATER_CHEATER_PUMPKIN_EATER)

const FROM_THE_TOP: String = "FROM_THE_TOP"

func set_from_the_top() -> void:
	set_achievement(FROM_THE_TOP)

## dot count achievements

const TEN_DOTS: String = "TEN_DOTS"

func set_ten_dots() -> void:
	set_achievement(TEN_DOTS)

const FIFTY_DOTS: String = "FIFTY_DOTS"

func set_fifty_dots() -> void:
	set_achievement(FIFTY_DOTS)

const ONE_HUNDRED_DOTS: String = "ONE_HUNDRED_DOTS"

func set_one_hundred_dots() -> void:
	set_achievement(ONE_HUNDRED_DOTS)

const TWO_HUNDRED_DOTS: String = "TWO_HUNDRED_DOTS"

func set_two_hundred_dots() -> void:
	set_achievement(TWO_HUNDRED_DOTS)

const THREE_HUNDRED_DOTS: String = "THREE_HUNDRED_DOTS"

func set_three_hundred_dots() -> void:
	set_achievement(THREE_HUNDRED_DOTS)

const FOUR_HUNDRED_DOTS: String = "FOUR_HUNDRED_DOTS"

func set_four_hundred_dots() -> void:
	set_achievement(FOUR_HUNDRED_DOTS)

const FIVE_HUNDRED_DOTS: String = "FIVE_HUNDRED_DOTS"

func set_five_hundred_dots() -> void:
	set_achievement(FIVE_HUNDRED_DOTS)

const SIX_HUNDRED_DOTS: String = "SIX_HUNDRED_DOTS"

func set_six_hundred_dots() -> void:
	set_achievement(SIX_HUNDRED_DOTS)

const SEVEN_HUNDRED_DOTS: String = "SEVEN_HUNDRED_DOTS"

func set_seven_hundred_dots() -> void:
	set_achievement(SEVEN_HUNDRED_DOTS)

const EIGHT_HUNDRED_DOTS: String = "EIGHT_HUNDRED_DOTS"

func set_eight_hundred_dots() -> void:
	set_achievement(EIGHT_HUNDRED_DOTS)

const NINE_HUNDRED_DOTS: String = "NINE_HUNDRED_DOTS"

func set_nine_hundred_dots() -> void:
	set_achievement(NINE_HUNDRED_DOTS)

const ONE_THOUSAND_DOTS: String = "ONE_THOUSAND_DOTS"

func set_one_thousand_dots() -> void:
	set_achievement(ONE_THOUSAND_DOTS)

const ALL_THE_DOTS: String = "ALL_THE_DOTS"

func set_all_the_dots() -> void:
	set_achievement(ALL_THE_DOTS)
