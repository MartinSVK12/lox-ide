#Saves/Loads game data to files with the ".var" extension using str_to_var and var_to_str
extends Node

func save_node_properties(node, file_name, path, whitelist=[]):
	Logger.info("Saving properties of: "+str(node.name))
#	print("Whitelist: "+str(whitelist))
	var data = {} #properties and their values will be stored here
	if whitelist.is_empty():
		var props = node.get_property_list()
		for prop in props.size():
			var prop_name = props[prop]["name"]
			var prop_value = node.get(prop_name)
			data[prop_name] = prop_value
	else:
		for prop in whitelist:
			data[prop] = node.get(prop)
	if !DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_recursive_absolute(path)
	var f = FileAccess.open(path.path_join(file_name)+".var",FileAccess.WRITE)
	var r = f.get_error() if is_instance_valid(f) else ERR_DOES_NOT_EXIST
	if r != OK:
		Logger.error("Err opening file: "+str(error_string(r)))
		print_stack()
	else:
		f.store_string(var_to_str(data))
		Logger.info("Node properties saved!")
#
#func save_node(node, file_name, path):
#	print("Saving node: "+node.name)
#	var scene = PackedScene.new()
#	set_owner_recursive(node,node)
#	var r = scene.pack(node)
#	if !DirAccess.dir_exists_absolute(path):
#		DirAccess.make_dir_absolute(path)
#	var r2 = ResourceSaver.save(path.path_join(file_name)+".tscn",scene)
#	if r != OK:
#		push_error("Can't pack node: "+error_string(r))
#	if r2 != OK:
#		push_error("Can't save node: "+error_string(r2])
#	else:
#		print("Saving node data..")
#		var data = {
#			"parent":node.get_parent().get_path(),
#			"sibling_pos":node.get_index()
#		}
#		save_any_data(data,path,file_name+"_data")
#		print("Node saved!")
#
#func set_owner_recursive(start,start_owner):
#	for node in start.get_children():
#		node.set_owner(start_owner)
#		set_owner_recursive(node,start_owner)

	

#var timer_data = []
#func find_timers(start):
#	for node in start.get_children():
#		if node is Timer:
#			if node.time_left > 0:
#				timer_data.append({"path":node.get_path(),"time":node.time_left})
#		find_timers(node)

func save_game():
	Logger.info("Saving game..")

func load_game():
	Logger.info("Loading game..")

func save_data(data, path, section="save"):
	Logger.info("Saving data '"+path+"' of length: "+str(data.size()))
	if !DirAccess.dir_exists_absolute("user://".path_join(section)):
		DirAccess.make_dir_absolute("user://".path_join(section))
	var f = FileAccess.open("user://".path_join(section).path_join(path)+".var",FileAccess.WRITE)
	var r = f.get_error() if is_instance_valid(f) else ERR_DOES_NOT_EXIST
	if r != OK:
		Logger.error("err opening file: "+str(error_string(r)))
		print_stack()
	else:
		f.store_string(var_to_str(data))
		Logger.info("Data saved!")
		
func save_any_data(data:Variant,file_name:String,path:String):
	Logger.info("Saving data '"+file_name+"' at "+path)
	if !DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_absolute(path)
	var f = FileAccess.open(path.path_join(file_name)+".var",FileAccess.WRITE)
	var r = f.get_error() if is_instance_valid(f) else ERR_DOES_NOT_EXIST
	if r != OK:
		Logger.error("Err opening file: "+str(error_string(r)))
		print_stack()
	else:
		f.store_string(var_to_str(data))
		Logger.info("Data saved!")
		
func save_data_internal(data, path):
	Logger.info("Saving data '"+path+"' of length: "+str(data.size()))
	var f = FileAccess.open("res://"+path+".var",FileAccess.WRITE)
	var r = f.get_error() if is_instance_valid(f) else ERR_DOES_NOT_EXIST
	if r != OK:
		Logger.error("err opening file: "+str(error_string(r)))
		print_stack()
	else:
		f.store_string(var_to_str(data))
		Logger.info("Data saved!")
	
func load_node_properties(node,file_name, path):
	Logger.info("Loading properties for: "+str(node.name))
	var f = FileAccess.open(path.path_join(file_name)+".var",FileAccess.READ)
	var r = f.get_error() if is_instance_valid(f) else ERR_DOES_NOT_EXIST
	if r != OK:
		Logger.error("err opening file: "+str(error_string(r)))
		print_stack()
	else: 
		var raw_data = f.get_as_text()
		var data = str_to_var(raw_data)
		if typeof(data) == TYPE_DICTIONARY:
			for prop in data:
				node.set(prop,data[prop])
			Logger.info("Loaded!")
		else:
			Logger.error("invalid type, file corrupted?")
			print_stack()
		
#
#func load_node(file_name,path,replace=false):
#	print("Loading node: "+path.path_join(file_name)+".tscn")
#	print("Loading node data..")
#	var parent = null
#	var sibling_pos = null
#	var data = load_any_data(path.path_join(file_name)+"_data.tscn")
#	if data != null:
#		parent = get_node_or_null(data["parent"])
#		if parent == null:
#			push_error("Node failed to load, invalid parent.")
#			return
#		sibling_pos = data["sibling_pos"]
#		var node = load(path).instantiate()
#		if parent.has_node(node.name) and replace:
#			parent.get_node(node.name).free()
#		parent.add_child(node)
##		parent.move_child(node, sibling_pos)
#		print("Node loaded!")
#	else:
#		push_error("Node failed to load, failed to get node data.")
	
func load_data(path, section="save"):
	Logger.info("Loading data (user://): "+path)
	var path_full = "user://".path_join(section).path_join(path)
	var f = FileAccess.open(path_full+".var",FileAccess.READ)
	var r = f.get_error() if is_instance_valid(f) else ERR_DOES_NOT_EXIST
	if r != OK:
		Logger.error("err opening file: "+str(error_string(r)))
		print_stack()
		return null
	else: 
		var raw_data = f.get_as_text()
		var data = str_to_var(raw_data)
		if typeof(data) != TYPE_NIL:
			Logger.info("Data loaded!")
			return data
		else:
			Logger.error("invalid type, file corrupted?")
			print_stack()
			return null
		
func load_data_internal(path):
	Logger.info("Loading data (res://): "+path)
	var f = FileAccess.open("res://"+path+".var",FileAccess.READ)
	var r = f.get_error() if is_instance_valid(f) else ERR_DOES_NOT_EXIST
	if r != OK:
		Logger.error("err opening file: "+str(error_string(r)))
		print_stack()
		return null
	else: 
		var raw_data = f.get_as_text()
		var data = str_to_var(raw_data)
		if typeof(data) != TYPE_NIL:
			Logger.info("Data loaded!")
			return data
		else:
			Logger.error("invalid type, file corrupted?")
			print_stack()
			return null

func load_any_data(path,silent=false,default=null):
	if not silent:
		Logger.info("Loading data (system): "+path)
	var f = FileAccess.open(path,FileAccess.READ)
	var r = f.get_error() if is_instance_valid(f) else ERR_DOES_NOT_EXIST
	if r != OK:
		if not silent:
			Logger.error("err opening file: "+str(error_string(r)))
			print_stack()
		return default
	else: 
		var raw_data = f.get_as_text()
		var data = str_to_var(raw_data)
		if typeof(data) != TYPE_NIL:
			if not silent:
				Logger.info("Data loaded!")
			return data
		else:
			if not silent:
				Logger.error("invalid type, file corrupted?")
				print_stack()
			return default

#func load_large(path: String, type_hint: String = "PackedScene") -> Resource:
	#var canvas = CanvasLayer.new()
	#canvas.layer = 999
	#add_child(canvas)
	#var scene: Loading = Main.instance_scene("res://scenes/loading.tscn", canvas)
	#scene.start_loading(path, type_hint)
	#var resource = await scene.loading_completed
	#scene.queue_free()
	#return resource
