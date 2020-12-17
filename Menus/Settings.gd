extends Menu
var menustypes = ["generalui", "thefallen"]
var currentmenu = 0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# Called when the node enters the scene tree for the first time.
func _ready():
	$Modes.play(vars.previoussettingsscreen)
	$generalui.get_node("Music").pressed = vars.MusicEnabled
	$generalui.get_node("SFX").pressed = vars.SfxEnabled
	$generalui.get_node("Username").text = vars.Name
	$generalui.get_node("HostId").text = str(vars.HostId)
	$generalui.get_node("Fullscreen").pressed = OS.window_fullscreen
	for thing in $thefallen/checkboxes.get_children():
		if vars.fallenenabled.has(thing.name):
			thing.pressed = true
		else:
			 thing.pressed = false
	$thefallen/timelimitfallen.value = vars.fallenwaittime
		
func _on_Apply_pressed():
	if $generalui.get_node("Music").pressed and not vars.MusicEnabled:
		vars.MusicEnabled = true
	elif not $generalui.get_node("Music").pressed and vars.MusicEnabled:
		vars.MusicEnabled = false
	if $generalui.get_node("SFX").pressed and not vars.SfxEnabled:
		vars.SfxEnabled = true
	elif not $generalui.get_node("SFX").pressed and vars.SfxEnabled:
		vars.SfxEnabled = false
	vars.FullscreenEnabled = $generalui.get_node("Fullscreen").pressed
	if OS.window_fullscreen != vars.FullscreenEnabled:
		if OS.window_fullscreen == false:
			OS.window_fullscreen = true
		elif OS.window_fullscreen == true:
			OS.window_fullscreen = false
	vars.Name = $generalui.get_node("Username").text
	#hostid is actually the port the server will go to
	vars.HostId = int($generalui.get_node("HostId").text)
	vars.fallenenabled = []
	for option in $thefallen.get_node("checkboxes").get_children():
		if option.pressed:
			vars.fallenenabled.append(option.name)
	vars.fallenwaittime = $thefallen/timelimitfallen.value
	####Save File####
	
	vars.refresh_save_file()
	
	#################

	get_tree().change_scene("res://MainMenu.tscn")
func _on_Go_Back_pressed():
	get_tree().change_scene("res://MainMenu.tscn")


func _on_arrowketrightpress_pressed():
	currentmenu += 1
	if currentmenu > menustypes.size() - 1:
		currentmenu = 0
	$Modes.play(menustypes[currentmenu])


func _on_arrowketleftpress_pressed():
	currentmenu -= 1
	if currentmenu < 0:
		currentmenu = menustypes.size() - 1
	$Modes.play(menustypes[currentmenu])


func _on_Modes_animation_started(anim_name):
	vars.previoussettingsscreen = anim_name
