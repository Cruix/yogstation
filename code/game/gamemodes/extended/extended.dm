/datum/game_mode/extended
	name = "extended"
	config_tag = "extended"
	required_players = 0
	//reroll_friendly = 1
	yogstat_name = "extended"

/datum/game_mode/announce()
	world << "<B>The current game mode is - Extended Role-Playing!</B>"
	world << "<B>Just have fun and role-play!</B>"

/datum/game_mode/extended/pre_setup()
	return 1

/datum/game_mode/extended/post_setup()
	..()