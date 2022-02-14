extends Control


func _ready():
	pass

		
func _process(delta):
	if $Label.m >= 10:
		$Label.hide()
		$game_over.show()
