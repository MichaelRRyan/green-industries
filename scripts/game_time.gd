extends Label

var minutes = 0
var seconds = 0
var milliseconds = 0

func _process(delta):

	if milliseconds > 9:
		seconds += 1
		milliseconds = 0
		
	if seconds > 59 :
		minutes += 1
		seconds = 0
	
	set_text(str(minutes)+" : "+str(seconds)+" : "+str(milliseconds))
	
	if minutes >= 5 and minutes < 8:
		add_color_override("font_color", Color(1,1,0)) #halfway through
		
	if minutes >= 8 and minutes <=10:
		add_color_override("font_color", Color(1,0,0)) #halfway through
		
	if minutes >= 10:
		var _val = get_tree().change_scene("res://scenes/game_over.tscn")
		
		
func _on_Timer_timeout():
	milliseconds += 1
