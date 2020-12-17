extends Node
#=#
var debugrole = ""
#=#
var hasfallenwent = false
var presetmaxplayers = 6
var presetlobbyname = "Lobby"
var Gamemode = ""
var fallencount = 0
var Maxplayers = 8
var LobbyName = ""
var leftover_roles = []
var defendedplayer = ""
var loaded = false
var MusicEnabled = true
var SfxEnabled = true
var Name = "User"
var ReadyPlayers = 0
var HostId = 4839
var FullscreenEnabled = true
var playerinfos = {}
var curplayers = 0
var fallenenabled = ["villager", "fallen", "theif", "wizard", "palladin", "aethermage", "spy", "guardian", "restless", "seer", "hellspawn", "slime", "fallenseer", "chmo"]
var fallenwaittime = 2.5
var previoussettingsscreen = "generalui"
func refuseNewConnections(yesno):
	get_tree().refuse_new_network_connections = yesno
func refresh_save_file():
	var save_dict = {
		"host_id" : HostId,
		"username" : Name,
		"sfx" : SfxEnabled,
		"music" : MusicEnabled,
		"fullscreen" : FullscreenEnabled,
		"presetlobbyname" : presetlobbyname,
		"presetmaxplayers" : presetmaxplayers,
		"fallenenabled" : fallenenabled,
		"fallenwaittime" : fallenwaittime
		}
	var save_game = File.new()
	save_game.open("res://settings.json", File.WRITE)
	#change res to user when exporting
#	print(to_json(save_dict))
	save_game.store_string(to_json(save_dict))
	save_game.close()
func start_server():
	var peer = NetworkedMultiplayerENet.new()
	var result = peer.create_server(vars.HostId, vars.Maxplayers)
	if result == OK:
		get_tree().set_network_peer(peer)
		print("Game hosted")
	else:
		print("Failed to host game")
func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	if not loaded:
		print("Loaded Settings:")
		load_settings()
func load_settings():
###Change Res to user when exporting!@!@@!!@!!
		var save_game = File.new()
		if not save_game.file_exists("res://settings.json"):
			return # Error! We don't have a save to load.

		save_game.open("res://settings.json", File.READ)
		var savedata = parse_json(save_game.get_as_text())
		print(savedata)
		if savedata.has("music"):
			MusicEnabled = savedata["music"]
		if savedata.has("sfx"):
			SfxEnabled = savedata["sfx"]
		if savedata.has("username"):
			Name = savedata["username"]
		if savedata.has("fullscreen"):
			FullscreenEnabled = savedata["fullscreen"]
		if savedata.has("host_id"):
			HostId = savedata["host_id"]
		if savedata.has("presetmaxplayers"):
			presetmaxplayers = savedata["presetmaxplayers"]
		if savedata.has("presetlobbyname"):
			presetlobbyname = savedata["presetlobbyname"]
		if savedata.has("fallenenabled"):
			fallenenabled = savedata["fallenenabled"]
		if savedata.has("fallenwaittime"):
			fallenwaittime = savedata["fallenwaittime"]
		save_game.close()
		if OS.window_fullscreen != FullscreenEnabled:
			if OS.window_fullscreen == false:
				OS.window_fullscreen = true
			elif OS.window_fullscreen == true:
				OS.window_fullscreen = false
				OS.window_size = Vector2(1024, 605)
func _player_connected(playerid):
	curplayers = curplayers + 1
#	print("new_player_connected")
	rpc_id(playerid,"serversendinfo", vars.Gamemode, vars.LobbyName)	
func _player_disconnected(playerid):
	playerinfos.erase(playerid)
	curplayers = curplayers -1
remote func clientsendinfo(clientid, clientname):
	playerinfos[clientid] = {"Name": clientname, "ID":clientid}
#	print(playerinfos)
func assign_fallen_roles():
	var roles = fallenenabled.duplicate(true)
#	if fallenenabled.has("villager")
	if fallenenabled.has("fallen") and curplayers >= 5:
		roles.append("fallen")
	if fallenenabled.has("fallen") and curplayers >= 8:
		roles.append("fallen")
	if roles.size() < curplayers + 2:
		#This means we have to compensate for overflow of players. (add extra roles with villagers and fallen)	
		if fallenenabled.has("villager") and fallenenabled.has("fallen"):	
			#adding villagers and fallen
			roles.erase("villager")
			roles.erase("fallen")
			var leftovers = (curplayers + 2) - roles.size()
			leftovers = ((leftovers % 4) + leftovers) / 4
			while leftovers != 0:
				roles.append("villager")
				roles.append("villager")
				roles.append("villager")
				roles.append("fallen")
				leftovers -= 1
		elif fallenenabled.has("fallen"):
			#fill with fallen (hard mode ish)
			var leftovers = (curplayers + 2) - roles.size()
			while leftovers != 0:
				roles.append("fallen")
				leftovers -= 1
		else:
			#adding only villagers. Due to the way the game is played, if vill and fall disabled, we still default to fill with vill :(
			var leftovers = (curplayers + 2) - roles.size()
			while leftovers != 0:
				roles.append("villager")
				leftovers -= 1
	
	#NOW we have the finalized list of roles. We just need to assign them to players.
#	print(roles) 
	var rng = RandomNumberGenerator.new()

	rng.randomize()
	fallencount = 0
	for player in playerinfos:
		if vars.playerinfos[player]["Name"] == "DEBUG":
			roles.erase(debugrole)
	for player in playerinfos:
		if vars.playerinfos[player]["Name"] == "DEBUG":
			
			playerinfos[player]["FallenRole"] = debugrole
			if debugrole == "fallen":
				fallencount += 1
			rpc_id(player, "giverole", debugrole)
#		print(playerinfos[player]["Name"])
		else:
			var randomrole = roles[rng.randi_range(0, roles.size()-1)]
			playerinfos[player]["FallenRole"] = randomrole
			roles.erase(randomrole)
			if randomrole == "fallen":
				fallencount += 1
			rpc_id(player, "giverole", randomrole)
	rpc("startscene", "res://Games/TheFallen/thefallenrole.tscn")
#	print(playerinfos)
#	print(roles)
	leftover_roles = roles
#	print(leftover_roles)
	rpc("set_leftover_roles", leftover_roles)
remote func playersaysready():
	ReadyPlayers += 1
func sendrpc(command, arg):
	rpc(command, arg)
func sendrpcid(id, command, arg):
	rpc_id(id, command, arg)
remote func defend_player(id):
	defendedplayer = id
#	print(defendedplayer)
#	print(playerinfos[id]["Name"])
remote func finish_role():
	rpc("set_leftover_roles", leftover_roles)
	rpc("get_player_datas", playerinfos)
	get_tree().get_root().get_children()[2].role_finished()
	print("role finished")
remote func set_role(clientid, newrole):
	playerinfos[clientid]["FallenRole"] = newrole
remote func set_untaken_role(index, newrole):
	leftover_roles[index] = newrole
