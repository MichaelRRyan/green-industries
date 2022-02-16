extends AudioStreamPlayer

func _process(_delta):
	if get_node("AcceptDialog").visible:
		ObjectPool.return_node(self)
