extends Node2D
var nighthappened = false
func _ready():
	vars.hasfallenwent = false
	vars.ReadyPlayers = 0
	if vars.MusicEnabled:
		$TitleAnim.play("Intro")
	else:
		$TitleAnim.play("Quiet")
	ThemeSong.playing = false
	vars.assign_fallen_roles()

func _on_TitleAnim_animation_finished(anim_name):
	if anim_name != "Fade To Night":
		$AnimationPlayer.play("Passive")
	else:
		get_tree().change_scene("res://Games/TheFallen/FallenNight.tscn")
func _process(delta):
	$Readyplayers.text =  str(vars.ReadyPlayers) + "/" + str(vars.curplayers) + " players are ready"
	if vars.ReadyPlayers == vars.curplayers and nighthappened == false and vars.curplayers != 0:
		nighthappened = true
		vars.sendrpc("startscene", "res://Games/TheFallen/TheFallenNight.tscn")
		$TitleAnim.play("Fade To Night")
		$AnimationPlayer.stop()
		$SFX.stop()
		$MusicPlayer.stop()
