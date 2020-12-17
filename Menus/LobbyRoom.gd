extends Menu
var pastpeeps = 0
const NAMETAG = preload("res://UI/NameLabel.tscn")

func _enter_tree():
	vars.start_server()

func _ready():
	vars.refuseNewConnections(false)
	vars.playerinfos = {}
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	$advertiser.serverInfo["name"] = vars.LobbyName
	$advertiser.serverInfo["port"] = vars.HostId # This is important so the client knows what port to connect on
	$advertiser.serverInfo["max_players"] = vars.Maxplayers
	$Lobbyname.text = vars.LobbyName
	$PeopleConnected.text =  "0/" + str(vars.Maxplayers) + " players connected"
	$Info.text = "Gamemode: " + vars.Gamemode + ", Port: " + str(vars.HostId)
	
func _process(delta):
	if pastpeeps != vars.curplayers:
		pastpeeps = vars.curplayers
		#This is the script to display all the names of people on the server and  update the number of people connected.
		var t = Timer.new()
		t.set_wait_time(0.3)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		t.queue_free()
		for child in $GridContainer.get_children():
			child.queue_free()
		for player in vars.playerinfos:
			var nametag = NAMETAG.instance()
			nametag.get_node("Label").text = vars.playerinfos[player]["Name"]
			$GridContainer.add_child(nametag)
			
		$PeopleConnected.text = str(vars.curplayers) + "/" + str(vars.Maxplayers) + " players connected"

func _on_Exit_pressed():
	vars.curplayers = 0
	get_tree().set_network_peer(null)
	get_tree().change_scene("res://Menus/GameSelection.tscn")


func _on_Start_pressed():
	vars.refuseNewConnections(false)
	if vars.Gamemode == "The Fallen" and vars.curplayers > 2:
		#Fallen Gamemode
		ThemeSong.playing = false
		get_tree().change_scene("res://Games/TheFallen/TheFallenWaiting.tscn")
