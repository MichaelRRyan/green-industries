extends Control

var game_over_lose = false 
var game_over_win = false 
var pollution_percentage = 0
var money_left = 0
var bankruptcy = 0


func _on_Restart_Button_pressed():
	var _set = get_tree().change_scene("res://scenes/main_menu.tscn");

func lose_conditions(var lose):
	if lose == true:
		$ColorRect/Condition.text = " You Lose "
		#$Condition.text = " You Win "

func _process(_delta):
	total_Pollution()
	money_left()
	broke()
# CHECKS THE STATS OF THE POLLUTION----------------------------------------------
func total_Pollution() :
	var pollution_stats = Pollution.total()
	$pollution/poll_perctange.text = str(pollution_stats) + "% "
	
	if pollution_stats <= 50: # DID GREAT
		$pollution/poll_perctange.add_color_override("font_color", Color(0,1,0)) #goes green
		$pollution.add_color_override("font_color", Color(0,1,0)) #goes green
		
	if pollution_stats > 50 and pollution_stats <=70: # COULD DO BETTER
		$pollution/poll_perctange.add_color_override("font_color", Color(1,1,0)) #goes yellow
		$pollution.add_color_override("font_color", Color(1,1,0))# goes yellow
		
	if pollution_stats > 70 and pollution_stats <=100: # DID BAD
		$pollution/poll_perctange.add_color_override("font_color", Color(1,0,0)) #goes red
		$pollution.add_color_override("font_color", Color(1,0,0))# goes red

# SEES HOW MUCH MONEY YOU HAVE LEFT
func money_left():
	var money = GetGameStat.stats
	$money/money_left.text = str(money)
	if money >= 0:
		$money/money_left.add_color_override("font_color", Color(0,1,0))
		$money.add_color_override("font_color", Color(0,1,0))
	else:
		$money/money_left.add_color_override("font_color", Color(1,0,0))
		$money.add_color_override("font_color", Color(1,0,0))


#checks to see how many times you went bankrupt
func broke():
	$bankrupt/bankrupt_count.text = str(GetGameStat.bankrupt)
	if GetGameStat.bankrupt == 0 :
		$bankrupt/bankrupt_count.add_color_override("font_color", Color(1,0,0))
		$bankrupt.add_color_override("font_color", Color(1,0,0))
	else: 
		$bankrupt/bankrupt_count.add_color_override("font_color", Color(0,1,0))
		$bankrupt.add_color_override("font_color", Color(0,1,0))
