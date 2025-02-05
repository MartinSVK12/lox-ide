extends VBoxContainer


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for c in get_children():
		c.queue_free()
	for err in ErrorBar.current_errors:
		var packed = load("res://src/main/gd/scenes/error_line.tscn") as PackedScene
		var line = packed.instantiate() as LineEdit
		line.expand_to_text_length = true
		line.text = err
		add_child(line)
