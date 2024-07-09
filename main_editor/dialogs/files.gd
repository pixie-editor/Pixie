extends FileDialog


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_file_selected(path):
	var image_window_scene = load("res://main_editor/pixie_image/pixie_image_window.tscn")
	var image_window = image_window_scene.instantiate()
	image_window.start_from_path(path)
	EDITOR.get_node("windows").add_child(image_window)
	EDITOR.get_node("canvas/popups").visible = false
	queue_free()

func _on_canceled():
	visible = false
