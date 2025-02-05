extends MenuButton

enum {
	OPEN_FILE = 0,
	OPEN_FOLDER = 1,
	CLOSE_FOLDER = 3
}

var current_action = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_popup().id_pressed.connect(_on_id_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_id_pressed(id: int):
	match id:
		OPEN_FILE:
			current_action = OPEN_FILE
			%FileDialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
			%FileDialog.popup()
		OPEN_FOLDER:
			current_action = OPEN_FOLDER
			%FileDialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
			%FileDialog.popup()
		CLOSE_FOLDER:
			get_tree().current_scene.current_folder = ""
			%ProjectStructureTree.clear()
			for c in %ScriptTabs.get_children():
				c.queue_free()


func _on_file_dialog_file_selected(path: String) -> void:
	if current_action == OPEN_FILE:
		%ProjectStructureTree.load_file(path)
		get_tree().get_current_scene().current_file = path


func _on_file_dialog_dir_selected(dir: String) -> void:
	if current_action == OPEN_FOLDER:
		%ProjectStructureTree.load_folder(dir)
		get_tree().get_current_scene().current_folder = dir
		

func _on_file_dialog_canceled() -> void:
	current_action = -1
