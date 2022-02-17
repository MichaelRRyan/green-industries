class_name States

class IdleState:
	extends State
	
	func enter(_msg : = {}) -> void:
		print ("Entered idle")
	
	func exit(_msg : = {}) -> void:
		print ("Exited idle")
	
	func update(_delta : float) -> void:
		pass

class NoResourceState:
	extends State
	
	func enter(_msg : = {}) -> void:
		print ("Entered no resource state")
	
	func exit(_msg : = {}) -> void:
		print ("Exited no resource state")
	
	func update(_delta : float) -> void:
		pass

class NoLandState:
	extends State
	func enter(_msg : = {}) -> void:
		print ("Entered no land state")
	
	func exit(_msg : = {}) -> void:
		print ("Exited no land state")
	
	func update(_delta : float) -> void:
		pass
