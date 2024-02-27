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

## init ########################################################3

func _init() -> void:
	OS.set_environment("SteamAppId", str(STEAM_APP_ID))
	OS.set_environment("SteamGameId", str(STEAM_APP_ID))

## ready ########################################################3

func _ready():
	# if not OS.has_feature("steam"):
	# 	return
	init_steam()

## process ########################################################3

func _process(_delta):
	# if not OS.has_feature("steam"):
	# 	return
	Steam.run_callbacks()

## init steam ########################################################3

func init_steam() -> void:
	var status = Steam.steamInitEx()

	if status.get("status") != 0:
		Log.warn("Steam init failed, disabling steam interactions", status)
		enabled = false
		return

	Log.pr("Steam init success, enabling steam interactions", status)
	enabled = true

	# Gather additional data
	is_on_steam_deck = Steam.isSteamRunningOnSteamDeck()
	is_online = Steam.loggedOn()
	is_owned = Steam.isSubscribed()
	steam_id = Steam.getSteamID()
	steam_username = Steam.getPersonaName()

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
		Steam.setAchievement(achv)
		Steam.storeStats()

func clear_achievement(achv):
	if enabled:
		Steam.clearAchievement(achv)
		Steam.storeStats()

func clear_test_achievements():
	clear_achievement(TEST_ACHIEVEMENT)

const TEST_ACHIEVEMENT="TEST_ACHIEVEMENT"

func set_test_achievement():
	set_achievement(TEST_ACHIEVEMENT)
