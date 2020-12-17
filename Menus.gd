extends Node2D
class_name Menu
func _ready():
	set_process(true)
	if vars.MusicEnabled == true and ThemeSong.playing == false:
		ThemeSong.playing = true
	elif vars.MusicEnabled == false and ThemeSong.playing == true:
		ThemeSong.playing = false
	
