extends CodeEdit
class_name ScriptEdit

var keywords := ["and", "class", "else", "false", "for", 
"fun", "if", "nil", "or", "print", "return", "super", 
"this", "true", "var", "while", "break", "continue", 
"static", "native", "interface", "is", "isnt", "import", 
"dynamic", "any", "string", "number", "boolean", "function", 
"class", "as", "init"]

var type_keywords := ["any", "string", "number", "boolean", "function", "class", "nil"]
var control_keywords := ["if","else","while","for","return","and","or","break","continue","is","isnt","as"]

@export var file: String = ""

func _ready() -> void:
	text = FileAccess.get_file_as_string(file)
	$"./Highlighter".update_cache()
	pass

func _on_breakpoint_toggled(line: int) -> void:
	pass
	#print("breakpoint toggled at "+str(line))

func _on_code_completion_requested() -> void:
	pass # Replace with function body.

func _on_symbol_hovered(symbol: String, line: int, column: int) -> void:
	pass
	#print("symbol hovered: {0} at {1}:{2}".format([symbol,line,column]))

func _on_symbol_lookup(symbol: String, line: int, column: int) -> void:
	pass
	#print("symbol lookup: {0} at {1}:{2}".format([symbol,line,column]))

func _on_symbol_validate(symbol: String) -> void:
	if(keywords.has(symbol)): set_symbol_lookup_word_as_valid(false); return
	set_symbol_lookup_word_as_valid(true)
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("save"):
		save()

func save():
	var f = FileAccess.open(file,FileAccess.WRITE)
	if f == null: return
	f.store_string(text)
	f.close()
	get_tree().get_root().set_input_as_handled()
