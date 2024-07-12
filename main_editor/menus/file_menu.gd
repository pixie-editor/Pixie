extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_open_men_pressed():
	if EDITOR.current_path == "":
		var home_path := OS.get_environment("USERPROFILE") if OS.has_feature("windows") else OS.get_environment("HOME")
		EDITOR.current_path = home_path
	var fmenu_scene = load("res://main_editor/dialogs/files.tscn")
	EDITOR.get_node("ui_animator").play("file_close")
	EDITOR.menuopen[1] = false
	EDITOR.get_node("canvas/popups").add_child(fmenu_scene.instantiate())
func _on_new_image_pressed():
	var image_window_scene = load("res://main_editor/pixie_image/pixie_image_window.tscn")
	var image_window = image_window_scene.instantiate()
	image_window.image_name = "new"
	image_window.canvas_size = Vector2(100, 100)
	EDITOR.get_node("windows").add_child(image_window)
	EDITOR.get_node("canvas/popups").visible = false
	EDITOR.get_node("ui_animator").play("file_close")
	


func _on_exit_men_pressed():
	Nodes.__quit_pixie()
