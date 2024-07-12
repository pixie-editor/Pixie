extends Control
var toolbox

func load_tools(selected):
	toolbox = $swatchboardbg/toolboxunder/toolbox
	for tool_i in selected:
		var tool = Nodes.tools[tool_i]
		var text = ImageTexture.create_from_image(tool.preview_image)
		toolbox.add_item(tool.name, text)
		print("loaded tool " + tool.name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_toolbox_item_selected(i):
	var tool = Nodes.tools[EDITOR.selected_window.selected_tools[i - 1]]
	EDITOR.tool = tool
	var options = $swatchboardbg/toolboxoptions
	tool.set_cursor()
	for child in options.get_children():
		options.remove_child(child)
	for item in tool.get_options():
		options.add_child(item)


func _on_swatchboard_mouse_entered():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if EDITOR.CURSOR != null:
		EDITOR.CURSOR.visible = false

func _on_leavearea_mouse_entered():
	if EDITOR.CURSOR != null:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		EDITOR.CURSOR.visible = true
