extends Button
class_name ShowHideButton

@export var component: Control

func _on_toggled(toggled_on: bool) -> void:
	component.visible = toggled_on
