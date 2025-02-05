extends TabContainer


func _on_tab_button_pressed(tab: int) -> void:
	get_tab_control(tab).queue_free()


func _on_tab_selected(tab: int) -> void:
	get_tree().get_current_scene().current_file = get_tab_control(tab).file


func _on_tab_changed(tab: int) -> void:
	if get_tab_control(tab) == null:
		get_tree().get_current_scene().current_file = ""
		return
	get_tree().get_current_scene().current_file = get_tab_control(tab).file
