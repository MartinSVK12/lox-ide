extends PanelContainer

var current_file: String
var current_folder: String

var folders: Array[String] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if FileAccess.file_exists("user://save/workspace.var"):
		var data = SaveSystem.load_data("workspace")
		if data != null:
			if data[1] != "":
				current_folder = data[1]
				%ProjectStructureTree.load_folder(data[1])
			if data[2] != null:
				for file in data[2]:
					%ProjectStructureTree.load_file(file)
			if data[0] != "":
				current_file = data[0]
				%ProjectStructureTree.load_file(data[0])

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		var opened_files = []
		for c in %ScriptTabs.get_children():
			if c is ScriptEdit:
				c.save()
				opened_files.append(c.file)
		SaveSystem.save_data([current_file,current_folder,opened_files],"workspace")

func _process(delta: float) -> void:
	var w_x = get_tree().get_root().size.x
	var w_y = get_tree().get_root().size.y
	
	position = Vector2.ZERO
	$Screen.position = Vector2.ZERO
	$Screen.size = Vector2(w_x,w_y)
