extends ColorRect
class_name MoveBar

var holding = false
var start_pos: Vector2
var current_pos: Vector2

enum Type { HORIZONTAL, VERTICAL}

@export var type: Type
@export var subject: Control

func _process(delta: float) -> void:
	if not subject.get_children().any(func(c): return !(c is MoveBar) && c.visible):
		subject.custom_minimum_size = Vector2.ZERO
	
	var w_x = get_tree().get_root().size.x
	var w_y = get_tree().get_root().size.y
	
	visible = subject.visible
	
	subject.position = subject.position.clamp(Vector2.ZERO,Vector2(w_x,w_y))
	

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		holding = event.pressed
		start_pos = get_global_mouse_position()
		current_pos = get_global_mouse_position()
		#subject.custom_minimum_size.x = subject.size.x
		#subject.custom_minimum_size.y = subject.size.y
	if holding and event is InputEventMouseMotion:
		current_pos = get_global_mouse_position()
		match type:
			HORIZONTAL:
				subject.custom_minimum_size.x = abs(current_pos.x - start_pos.x)
				pass
			VERTICAL:
				subject.custom_minimum_size.y = abs(current_pos.y - start_pos.y)
				pass
