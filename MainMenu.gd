extends Menu

export var mode = ""

func _ready():
	if not vars.loaded:
		ThemeSong.playing = vars.MusicEnabled
		vars.loaded = true

func _on_Host_pressed():
	get_tree().change_scene("res://Menus/GameSelection.tscn")

func _on_Setup_pressed():
	get_tree().change_scene("res://Menus/Settings.tscn")

func _on_Exit_pressed():
	get_tree().quit()

func _on_Credits_pressed():
	get_tree().change_scene("res://Menus/Credits.tscn")
