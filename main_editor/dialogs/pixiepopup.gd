extends Window
var margins = Vector2(5, 5)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_ui(element_data):
	var container = $container
	for child in container.get_children():
		container.remove_child(child)
	var splits = element_data.split(";")
	var current_container = null
	var container_max = 1
	var container_count = 1
	for split in splits:
		var data_sections = split.split("|")
		var new_element = null
		if data_sections[0] == "L":
			new_element = Label.new()
			new_element.text = data_sections[1]
		elif data_sections[0] == "B":
			new_element = Button.new()
			new_element.text = data_sections[1]
			var button_action = data_sections[2].split(":")
			var button_call = null
			if button_action[0] == "builtin":
				if len(button_action) == 1:
					print(button_action)
					new_element.text = new_element.text + " error in button: action requested but none given"
				else:
					new_element.pressed.connect(Nodes.builtins[button_action[1]])
		elif data_sections[0] == "H":
			new_element = HSeparator.new()
		elif data_sections[0] == "T":
			# toolbox
			pass
		elif data_sections[0] == "C":
			# color
			pass
		elif data_sections[0] == "I":
			pass
		else:
			new_element = Label.new()
			new_element.text = "UI error: no element named " + data_sections[0]
		# image
		$container.add_child(new_element)
		new_element.position.x += margins.x
		new_element.position.y += margins.y
func load_ui():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
# "Label|Hello world|12;Label|Sample Text"
