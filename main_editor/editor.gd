extends Control
const version = "1-a"
var menuopen = [false, false, false, false]
var current_path = ""
var zoom_level = 1
const ZOOM_SPEED = .25
const ZOOM_MAX = 10000
const ZOOM_MIN = -10000
var SPEED = 6
var enabled : bool = false
var CURSOR = null
var DRAGGING = false
var selected_window : Control
var selected_nodes = []
var tool : Nodes.Tool

func _ready():
	pass # Replace with function body.
	
func _process(delta):
	# camera zoom
	if not enabled:
		return
	var curr_zoom = $maincam.zoom
	if Input.is_action_just_released("zoom_out") and zoom_level > ZOOM_MIN:
		zoom_level -= ZOOM_SPEED
		curr_zoom -= Vector2(ZOOM_SPEED, ZOOM_SPEED)
		$maincam.zoom = curr_zoom
	elif Input.is_action_just_released("zoom_in") and zoom_level < ZOOM_MAX:
		zoom_level += ZOOM_SPEED
		curr_zoom += Vector2(ZOOM_SPEED, ZOOM_SPEED)
		$maincam.zoom = curr_zoom
	if DRAGGING:
		pass
	if CURSOR != null:
		CURSOR.position = get_viewport().get_mouse_position()
	# camera movement
	var input_vector = Vector2.ZERO
	var current_anim : String = "idle-"
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	if input_vector.y == -1:
		$maincam.position.y -= SPEED
	elif input_vector.y == 1:
		$maincam.position.y += SPEED
	if input_vector.x == -1:
		$maincam.position.x -= SPEED
	elif input_vector.x == 1:
		$maincam.position.x += SPEED

func _on_file_men_pressed():
	var open = menuopen[1]
	if open:
		$ui_animator.play("file_close")
	else:
		$ui_animator.play("file_drop")
	menuopen[1] = not open

func load_tools(message : Label, prog : ProgressBar):
	message.text = "loading tool configurations"
	var cursor_tool = Nodes.Tool.new()
	cursor_tool.name = "multi-select"
	var dirs = Nodes.readdir("user://tools")
	var max_prog = len(dirs) / (100 - prog.value)
	for file in dirs:
		message.text = "reading tools ... " + file 
		file = FileAccess.open("user://tools/" + file, FileAccess.READ)
		var content = file.get_as_text()
		Nodes.append_tools_from_string(content, message, prog, max_prog)
	Nodes.tools.append(Nodes.Select.new())
	Nodes.tools.append(Nodes.BaseBrush.new())

func load_ps(path : String):
	var actions : Dictionary = {}
	var loaded_data = ""

