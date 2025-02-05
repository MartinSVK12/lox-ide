extends Label

func _process(delta: float) -> void:
	if %ScriptTabs.get_current_tab_control() != null:
		if get_tree().get_current_scene().current_folder != "":
			set_text("{4}:{5} | FPS: {0} | Display: {1}x{2} | Folder: {3}".format(
				[
					Engine.get_frames_per_second(),
					get_tree().get_root().size.x,
					get_tree().get_root().size.y,
					get_tree().get_current_scene().current_folder,
					(%ScriptTabs.get_current_tab_control() as CodeEdit).get_caret_line()+1,
					(%ScriptTabs.get_current_tab_control() as CodeEdit).get_caret_column()+1
				]
			))
		else:
			set_text("{4}:{5} | FPS: {0} | Display: {1}x{2}".format(
				[
					Engine.get_frames_per_second(),
					get_tree().get_root().size.x,
					get_tree().get_root().size.y,
					(%ScriptTabs.get_current_tab_control() as CodeEdit).get_caret_line()+1,
					(%ScriptTabs.get_current_tab_control() as CodeEdit).get_caret_column()+1
				]
			))
	else:
		if get_tree().get_current_scene().current_folder != "":
			set_text("FPS: {0} | Display: {1}x{2} | Folder: {3}".format(
				[
					Engine.get_frames_per_second(),
					get_tree().get_root().size.x,
					get_tree().get_root().size.y,
					get_tree().get_current_scene().current_folder
				]
			))
		else:
			set_text("FPS: {0} | Display: {1}x{2}".format(
				[
					Engine.get_frames_per_second(),
					get_tree().get_root().size.x,
					get_tree().get_root().size.y,
				]
			))
