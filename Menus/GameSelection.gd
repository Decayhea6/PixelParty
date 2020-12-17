extends Menu

func _ready():
	$Lobbyname.text = vars.presetlobbyname
#	$Gameselect.add_item("Chat")
	$Gameselect.add_item("The Fallen")
#	$Gameselect.text = "Choose an Option"
	$Maxplayers.value = vars.presetmaxplayers


func _on_Back_pressed():
	get_tree().change_scene("res://MainMenu.tscn")
	vars.presetmaxplayers = $Maxplayers.value
	vars.presetmaxplayers = $Maxplayers.value
	vars.refresh_save_file()
	
func _on_Continue_pressed():
	vars.Gamemode = $Gameselect.text
	vars.Maxplayers = $Maxplayers.value
	vars.presetmaxplayers = $Maxplayers.value
	vars.LobbyName = $Lobbyname.text
	vars.presetlobbyname = $Lobbyname.text
	vars.refresh_save_file()
	if $Gameselect.text == "The Fallen" and vars.Maxplayers > 2:
		get_tree().change_scene("res://Menus/LobbyRoom.tscn")
