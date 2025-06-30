extends CodeEdit
class_name ScriptEdit

var keywords := ["and", "class", "else", "false", "for", "fun", "init", "if", "nil", "or", "return", "super", "this", "true", "var", "val", "while", "break", "continue", "static", "native", "interface", "is", "isnt", "import", "as", "extends", "implements", "try", "catch", "throw"]

var type_keywords := ["Any", "String", "Number", "Boolean", "Function", "Class", "Nil", "Generic", "Array"]
var control_keywords := ["if","else","while","for","return","and","or","break","continue","is","isnt","as"]

@export var file: String = ""

func _ready() -> void:
	text = FileAccess.get_file_as_string(file)
	var s: CodeHighlighter = (syntax_highlighter as CodeHighlighter)
	s.clear_color_regions()
	s.clear_keyword_colors()
	s.clear_member_keyword_colors()
	for keyword in keywords:
		s.add_keyword_color(keyword, Color("ff697d"))
	for keyword in type_keywords:
		s.add_keyword_color(keyword, Color.DARK_ORANGE)
	for keyword in control_keywords:
		s.add_keyword_color(keyword, Color("f788c6"))
	s.add_color_region("//","",Color.WEB_GRAY,true)
	s.add_color_region("\"","\"",Color("e3d23d"))
	#$"./Highlighter".update_cache()
	#symbol_hovered.connect((get_tree().current_scene.get_node("CodeAnalysis") as CodeAnalysis)._on_symbol_hovered, CONNECT_REFERENCE_COUNTED)
	pass

func _on_breakpoint_toggled(line: int) -> void:
	pass
	#print("breakpoint toggled at "+str(line))

func _on_code_completion_requested() -> void:
	pass # Replace with function body.

func _on_symbol_hovered(symbol: String, line: int, column: int) -> void:
	if(!is_valid_symbol(symbol)): return
	if(get_line(line).begins_with("//")): return
	var type: String = (get_tree().current_scene.get_node("CodeAnalysis") as CodeAnalysis)._on_symbol_hovered(symbol, line, column)
	#print(type)
	%TypePopup.show()
	%TypePopup.global_position = get_global_mouse_position() - Vector2(0,42)
	%TypePopup.text = type
	%TypePopup.size = Vector2.ZERO
	#set_code_hint_draw_below(false)
	#set_code_hint(type)
	#request_code_completion(true)
	#add_code_completion_option(CodeCompletionKind.KIND_PLAIN_TEXT, type, "")
	#update_code_completion_options(true)

func _on_symbol_lookup(symbol: String, line: int, column: int) -> void:
	pass
	#print("symbol lookup: {0} at {1}:{2}".format([symbol,line,column]))

func _on_symbol_validate(symbol: String) -> void:
	set_symbol_lookup_word_as_valid(is_valid_symbol(symbol))
	
func is_valid_symbol(symbol: String) -> bool:
	if(keywords.has(symbol)): return false
	return true
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("save"):
		save()

func save():
	var f = FileAccess.open(file,FileAccess.WRITE)
	if f == null: return
	f.store_string(text)
	f.close()
	get_tree().get_root().set_input_as_handled()


func _on_caret_changed() -> void:
	%TypePopup.hide()
