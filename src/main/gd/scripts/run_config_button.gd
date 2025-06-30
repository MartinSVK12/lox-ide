extends MenuButton
class_name RunConfigButton

var run_configs: Array[RunConfig] = []
var current: RunConfig = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_popup().id_pressed.connect(_on_id_pressed)
	pass # Replace with function body.

func _on_pressed() -> void:
	get_popup().clear(true)
	get_popup().add_item("Current File",998)
	get_popup().add_separator()
	for cfg in run_configs:
		get_popup().add_item(cfg.config_name)
	get_popup().add_icon_item(load("res://src/main/gd/assets/add_dark.svg"),"Add run configuration...",999)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_id_pressed(id: int):
	if id == 999:
		%AddRunConfigDialog/VBox/FileName.text = ""
		%AddRunConfigDialog/VBox/PathLine.text = ""
		if %ScriptTabs.get_current_tab_control() != null:
			%AddRunConfigDialog/VBox/FileName.text = (%ScriptTabs.get_current_tab_control() as ScriptEdit).file
			var s = ""
			for folder in (get_tree().current_scene.folders as Array[String]):
				s += folder+";"
			%AddRunConfigDialog/VBox/PathLine.text = s
		%AddRunConfigDialog.popup()
	else:
		if Input.is_physical_key_pressed(KEY_SHIFT):
			var index = get_popup().get_item_index(id)
			if index == 0: return
			%EditRunConfigDialog.cfg = run_configs[index-2]
			%EditRunConfigDialog.cfg_index = index
			%EditRunConfigDialog.popup()
		else:
			var index = get_popup().get_item_index(id)
			text = get_popup().get_item_text(index)
			if id != 998:
				current = run_configs[index-2]
			else:
				current = null

func _on_add_run_config_dialog_confirmed() -> void:
	var cfg = %AddRunConfigDialog/VBox/ConfigName.text
	var file = %AddRunConfigDialog/VBox/FileName.text
	var path = %AddRunConfigDialog/VBox/PathLine.text
	var opts = %AddRunConfigDialog/VBox/OptionsLine.text
	var args = %AddRunConfigDialog/VBox/LaunchArgsLine.text
	
	%AddRunConfigDialog/VBox/ConfigName.text = ""
	%AddRunConfigDialog/VBox/FileName.text = ""
	%AddRunConfigDialog/VBox/PathLine.text = ""
	%AddRunConfigDialog/VBox/OptionsLine.text = ""
	%AddRunConfigDialog/VBox/LaunchArgsLine.text = ""

	run_configs.append(RunConfig.new(cfg,file,path,opts,args))

class RunConfig:
	var config_name: String
	var file_name: String
	var load_path: String
	var options: String
	var launch_args: String
	
	func _init(cfg: String, file: String, path: String, opts: String, args: String) -> void:
		config_name = cfg
		file_name = file
		load_path = path
		options = opts
		launch_args = args
		pass


func _on_edit_run_config_dialog_custom_action(action: StringName) -> void:
	if action == "delete":
		var i = %EditRunConfigDialog.cfg_index
		var cfg = run_configs[i-2]
		if current == cfg:
			current = null
			text = get_popup().get_item_text(get_popup().get_item_index(998))
		run_configs.remove_at(i-2)
		%EditRunConfigDialog.visible = false
