extends Button

func _on_pressed() -> void:
	%ProjectStructureTree.load_folder(get_tree().current_scene.current_folder)
