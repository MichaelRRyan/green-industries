extends Node2D

var load_amount = 1
var object_pool : Dictionary = {}

var _return_queue : Array = []

func take_node(path : String):
	var object
	if !object_pool.has(path):
		_load_object(path)
	
	object = object_pool[path][0]
	var _r = object_pool[path].erase(object)
	
	if len(object_pool[path]) < 1:
		_r =  object_pool.erase(path)
	
	return object

func _load_object(path : String):
	var resource = load(path)
	for _i in load_amount:
		var object = resource.instance()
		if path in object_pool:
			object_pool[path].append(object)
		else:
			object_pool[path] = [object]

func return_node(object):
	if _return_queue.has(object):
		return
	_return_queue.append(object)

func _clean_return_queue():
	while len(_return_queue) != 0:
		var object = _return_queue.pop_front()
		
		if object != null:
			return
		var parent = object.get_parent()
		
		if parent == null:
			return
		
		parent.remove_child(object)
		if object_pool.has(object.filename):
			object_pool[object.filename].append(object)
		else:
			object_pool[object.filename] = [object]

func _process(_delta):
	_clean_return_queue()
