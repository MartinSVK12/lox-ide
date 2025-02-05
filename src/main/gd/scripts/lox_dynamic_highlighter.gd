extends Node
class_name LoxDynamicCodeHighlighter
	
var cache: Array[LineCache] = []
var colors: Dictionary = {}

@onready var t: TextEdit = $".."

var update = 0
var update_threshold = 250

signal send_update(d: Dictionary)

func _init() -> void:
	colors[G.NONE] = Color.WHITE
	colors[G.KEYWORD] = Color.ORANGE
	colors[G.TYPE] = Color.MEDIUM_SPRING_GREEN
	colors[G.TYPE_PARAM] = Color.LIGHT_SEA_GREEN
	colors[G.CONSTANT] = Color.LIGHT_CORAL
	colors[G.STRING] = Color.KHAKI
	colors[G.NUMBER] = Color.PALE_GREEN
	colors[G.COMMENT] = Color.LIGHT_GRAY
	colors[G.FUNCTION] = Color.SKY_BLUE
	colors[G.CLASS_NAME] = Color.SKY_BLUE
	colors[G.PROPERTY_DECL] = Color.HOT_PINK
	colors[G.SYMBOL] = Color.DARK_GRAY

func _ready() -> void:
	(t.syntax_highlighter as LoxHighlighterBase).request_update.connect(return_highlighting_data)
	(get_tree().current_scene.get_node("%CodeAnalysis") as CodeAnalysis).analysis_completed.connect(update_cache,CONNECT_REFERENCE_COUNTED)
	(get_tree().current_scene.get_node("%ScriptTabs") as TabContainer).tab_changed.connect(func(tab: int): update_cache(Array(),Array()),CONNECT_REFERENCE_COUNTED)
	update_cache(Array(),Array())

func return_highlighting_data(line: int):
	var c: Array[LineCache] = cache.filter(func(e: LineCache): return e.line == line)
	if(c.is_empty()): return { 0: {"color": Color.LIGHT_GRAY}}
	var comment = t.text.split('\n')[line]
	if(comment.contains("//")): return { comment.find("//"): {"color": Color.DIM_GRAY}}
	var d = { 0: {"color": Color.LIGHT_GRAY}}
	for lc in c:
		d[lc.start] = {"color": colors[lc.type]}
		d[lc.end] = {"color": Color.LIGHT_GRAY}
	
	(t.syntax_highlighter as LoxHighlighterBase).cache = d

func update_cache(errors: Array, tokens: Array) -> void:
	cache.clear()
	
	var keywords = tokens.filter(func(t): return t["type"] == "KEYWORDS")
	var strings = tokens.filter(func(t): return t["type"] == "LITERALS" and t["name"] == "STRING")
	var numbers = tokens.filter(func(t): return t["type"] == "LITERALS" and t["name"] == "NUMBER")
	var types = tokens.filter(func(t): return t["type"] == "TYPES")
	
	for keyword in keywords:
		highlight(keyword,G.KEYWORD)
		
	for s in strings:
		highlight(s,G.STRING)
		
	for n in numbers:
		highlight(n,G.NUMBER)
	
	for t in types:
		highlight(t,G.TYPE)
	
	(t.syntax_highlighter as LoxHighlighterBase).clear_highlighting_cache()
	(t.syntax_highlighter as LoxHighlighterBase).update_cache()

func highlight(token: Dictionary, type: G):
	var line: int = token["line"]-1
	var pos: Vector2i = token["pos"]
	cache.append(LineCache.new(line,token["lexeme"],pos.x,pos.y,type))

#func highlight(regex: String, types: Dictionary, special: String = "") -> void:
	#var r = RegEx.create_from_string(regex)
	#var lines = t.text.split('\n')
	#var i = 0
	#for l in lines:
		#var matches: Array[RegExMatch] = r.search_all(l)
		#for m in matches:
			#for key in types:
				#var value = types[key]
				#cache.append(LineCache.new(i,m.get_string(key),m.get_start(key),m.get_end(key),value))
		#i += 1

class LineCache:
	var type: G = G.NONE
	var line := 0
	var string := ""
	var start := 0
	var end := 0
	
	func _init(l: int,s: String,b: int,e: int,g: G) -> void:
		self.line = l
		self.string = s
		self.start = b
		self.end = e
		self.type = g
		
	func _to_string() -> String:
		return "'{0}' at [{1}::({2}:{3})] ({4})".format([string,line,start,end,type])

enum G {
	NONE,
	KEYWORD,
	TYPE,
	TYPE_PARAM,
	CONSTANT,
	STRING,
	NUMBER,
	COMMENT,
	FUNCTION,
	PROPERTY_DECL,
	SYMBOL,
	CLASS_NAME
}

func _input(event: InputEvent) -> void:
	pass
	#if event is InputEventKey:
		#update_cache()

func _on_timer_timeout() -> void:
	pass
	#update_cache()
