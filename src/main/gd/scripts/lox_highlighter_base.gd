class_name LoxHighlighterBase
extends SyntaxHighlighter

signal request_update(line: int)

var cache: Dictionary = {}

func _get_line_syntax_highlighting(line: int) -> Dictionary:
	request_update.emit(line)
	return cache
