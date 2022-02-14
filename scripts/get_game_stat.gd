extends Control


var stats = 0

var bankrupt = 0

func money(var euro):
	stats = euro
	if euro == 0:
		bankrupt+=1

