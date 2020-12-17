extends Node2D
var roles_no_wakeup = ["villager", "palladin", "voidspawn", "hellspawn", "chmo"]
var roles_left_to_go = []
var rolegoing = ""
var fallenfinished = 0
func _ready():
	vars.rpc("get_player_datas", vars.playerinfos)
	fallenfinished = 0
	vars.defendedplayer = ""
	if vars.SfxEnabled:
		$announcer.stream_paused = false
	else:
		$announcer.stream_paused = true
	if vars.MusicEnabled:
		$music.playing = true
	for player in vars.playerinfos:
		vars.playerinfos[player]["OGFallenRole"] = vars.playerinfos[player]["FallenRole"]
		if not vars.playerinfos[player]["OGFallenRole"] in roles_no_wakeup:  
			roles_left_to_go.append(vars.playerinfos[player]["OGFallenRole"])
	next_role()
func next_role():
	
	if roles_left_to_go.has("guardian"):
		rolegoing = "guardian"
	elif roles_left_to_go.has("fallen"):
		rolegoing = "fallen"
	elif roles_left_to_go.has("fallenseer"):
		rolegoing = "fallenseer"
	elif roles_left_to_go.has("seer"):
		rolegoing = "seer"
	elif roles_left_to_go.has("theif"):
		rolegoing = "theif"
	elif roles_left_to_go.has("aethermage"):
		rolegoing = "aethermage"
	elif roles_left_to_go.has("wizard"):
		rolegoing = "wizard"
	elif roles_left_to_go.has("slime"):
		rolegoing = "slime"
	elif roles_left_to_go.has("spy"):
		rolegoing = "spy"
	elif roles_left_to_go.has("restless"):
		rolegoing = "restless"
	else:
		#this means its empty, so we start voting
		$AnimationPlayer.play("fade_out")
		yield(get_tree().create_timer(2.5), "timeout")
		$AnimationPlayer.play("backtogrey")
		yield(get_tree().create_timer(2), "timeout")
		get_tree().change_scene("res://Games/TheFallen/FallenVoting.tscn")

	for player in vars.playerinfos:
		if vars.playerinfos[player]["OGFallenRole"] == rolegoing:
			vars.rpc_id(player, "get_protected", vars.defendedplayer)
			vars.rpc_id(player, "your_turn_to_go" ,vars.playerinfos[player]["OGFallenRole"])
			$AnimationPlayer.play(rolegoing)
			
func role_finished():
#	print("role_finished has been called")
	if rolegoing != "fallen" or fallenfinished == vars.fallencount-1:
		$AnimationPlayer.play("fade_out")
		#this next thing makes all the roles going go back to the original scene
		for player in vars.playerinfos:
			if vars.playerinfos[player]["OGFallenRole"] == rolegoing:
				vars.rpc_id(player, "startscene", "res://Games/TheFallen/TheFallenNight.tscn")
#				print("start_scene should be now called")
#		print(vars.playerinfos)
		yield(get_tree().create_timer(2.5), "timeout")
		while rolegoing in roles_left_to_go:
			roles_left_to_go.erase(rolegoing)
		next_role()
	else:
		fallenfinished += 1
	
