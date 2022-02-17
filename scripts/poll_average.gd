extends Control

onready var _pollution_manager = Utility.get_dependency("pollution_manager", self, true)

func show() -> void:
	if _pollution_manager:
		.show() # Calls show on the base class.
		
		$TotalTrees/Value.text = str(_pollution_manager._total_trees)
		$TotalPollution/Value.text = str(_pollution_manager.get_pollution_percentage())

	else:
		print_debug("No pollution manager could be found.")
