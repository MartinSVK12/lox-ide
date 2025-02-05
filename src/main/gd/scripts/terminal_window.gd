extends TextEdit


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Logger.info_logged.connect(log_string,CONNECT_REFERENCE_COUNTED)
	Logger.warn_logged.connect(log_string,CONNECT_REFERENCE_COUNTED)
	Logger.error_logged.connect(log_string,CONNECT_REFERENCE_COUNTED)
	pass # Replace with function body.

func log_string(color: bool, raw:bool, s: String):
	var r = RegEx.create_from_string(r'\[\/[^\]]*\]')
	var r2 = RegEx.create_from_string(r'\[[^\]]*=[^\]]*\]')
	if raw:
		s = r.sub(s,"",true)
		s = r2.sub(s,"",true)
		text += s
		return
	s = r.sub(s,"",true)
	s = r2.sub(s,"",true)
	text += s + "\n"


func _on_clear_terminal_button_pressed() -> void:
	text = ""
