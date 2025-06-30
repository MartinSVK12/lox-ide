extends ConfirmationDialog

var cfg: RunConfigButton.RunConfig = null
var cfg_index: int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_button("Delete",false,"delete")
	pass # Replace with function body.

func _on_about_to_popup() -> void:
	if cfg != null and cfg_index != -1:
		$VBox/ConfigName.text = cfg.config_name
		$VBox/FileName.text = cfg.file_name
		$VBox/PathLine.text = cfg.load_path
		$VBox/OptionsLine.text = cfg.options
		$VBox/LaunchArgsLine.text = cfg.launch_args
	else:
		$VBox/ConfigName.text = ""
		$VBox/FileName.text = ""
		$VBox/PathLine.text = ""
		$VBox/OptionsLine.text = ""
		$VBox/LaunchArgsLine.text = ""

func _on_confirmed() -> void:
	cfg.config_name = $VBox/ConfigName.text
	cfg.file_name = $VBox/FileName.text
	cfg.load_path = $VBox/PathLine.text
	cfg.options = $VBox/OptionsLine.text
	cfg.launch_args = $VBox/LaunchArgsLine.text
	
	$VBox/ConfigName.text = ""
	$VBox/FileName.text = ""
	$VBox/PathLine.text = ""
	$VBox/OptionsLine.text = ""
	$VBox/LaunchArgsLine.text = ""
