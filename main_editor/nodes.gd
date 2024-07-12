extends Node
var brushes = []
var tools = []
var USER_DIRECTORY = DirAccess.open("user://")
var not_setup : bool = true
var builtins : Dictionary
var controlled = null

class PSInterpreter:
	func parse_ps_array(s : String):
		var splits = s.substr(1, len(s) - 1).split(" ")
		var ret = []
		for split in splits:
			ret.append(int(split))
		return(ret)

var PixieScriptInterpreter = PSInterpreter.new()

func __quit_pixie():
	get_tree().quit()

func select_node(anything):
	controlled = anything
	
func __setup_directory():
	var error = DirAccess.make_dir_recursive_absolute("user://tools")
	var tools_file = FileAccess.open("user://tools/tools.txt", FileAccess.WRITE)
	var original_tools = FileAccess.open("res://base/tools.txt", FileAccess.READ)
	tools_file.store_string(original_tools.get_as_text())
	var lupdater = controlled.get_node("loading_updater")
	var loadbar = controlled.get_node("ProgressBar")
	var popup = controlled.get_node("pixiepopup")
	loadbar.value += 20
	var resp = "L|would you like to download an access token?|12;"
	resp = resp + "L|this allows pixie to be updated, and enables online features.|12;H;"
	popup.set_ui(resp + "B|no|builtin:load_tools;B|yes|builtin:generate_token")

func __generate_access_token():
	__load_brushes_and_tools()

func __load_brushes_and_tools():
	controlled.get_node("pixiepopup").visible = false
	var lupdater = controlled.get_node("loading_updater")
	var loadbar = controlled.get_node("ProgressBar")
	loadbar.value += 30
	lupdater.text = "loading tools"
	EDITOR.load_tools(lupdater, loadbar)
	controlled.get_node("anim").play("splash_out")
	not_setup = false

func __select_setup_dir():
	pass

func _ready():
	builtins = {"quit_pixie": __quit_pixie, "setup_directory": __setup_directory, 
	"select_setup_dir": __select_setup_dir, "load_tools": __load_brushes_and_tools, 
	"generate_token": __generate_access_token}

class ToolOption:
	var label : String = ""
	var type : String = "number"
	var value

class Tool:
	var name = "tool"
	var preview_image : Image = Image.new()
	var cursor_image : Image = Image.new()
	var tool_options = []
	func _init():
		set_tool_image()
	func set_tool_image():
		var err = self.preview_image.load("res://theme/icons/tool.png")
	func do_select(image):
		pass
	func do_alt():
		pass
	func do_middle():
		pass
	func set_cursor():
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		EDITOR.CURSOR = null
	func get_options():
		return([])

class Brush:
	extends Tool
	var brush_x = []
	var brush_y = []
	var brush_a = []
	var size = 15
	func set_tool_image():
		var err = self.preview_image.load("res://theme/icons/paintbrush.png")
		self.preview_image = Image.create(self.size, self.size, false, Image.FORMAT_RGBA8)
		for pos in range(0, len(brush_x)):
			self.preview_image.set_pixelv(Vector2i(brush_x[pos], brush_y[pos]), Color(1, 1, 1, brush_a[pos]))
	func set_brush_from_data(brushx , brushy, brusha, s = self.size):
		self.size = s
		self.brush_x = brushx
		self.brush_y = brushy
		self.brush_a = brusha
		set_tool_image()
	func set_brush_from_image():
		pass
	func set_brush_from_ps(ps):
		self.size = int(ps[1])
		self.brush_x = Nodes.PixieScriptInterpreter.parse_ps_array(ps[2])
		self.brush_y = Nodes.PixieScriptInterpreter.parse_ps_array(ps[3])
		self.brush_a = Nodes.PixieScriptInterpreter.parse_ps_array(ps[4])
		var n = len(ps)
		print(ps)
		if n > 4:
			for arg in range(5, n):
				print(ps[arg])
				if not ps[arg].contains("="):
					# TODO Warn the tool was  read incorrectly?
					continue
				elif ps[arg].contains("name"):
					var namesplits = ps[arg].split("=")
					print(namesplits)
					self.name = namesplits[1].lstrip(" ")
		set_tool_image()

class BaseBrush:
	extends Tool
	var size = 5
	var color = Color(1, 1, 1, 1)
	var brush : Brush
	func _init():
		name = "brush"
		brush = Nodes.brushes[1]
		set_tool_image()
		self.cursor_image = brush.preview_image
	func set_tool_image():
		var err = self.preview_image.load("res://theme/icons/paintbrush.png")
	func set_cursor():
		var cursor_image = TextureRect.new()
		cursor_image.texture = ImageTexture.create_from_image(brush.preview_image)
		EDITOR.CURSOR = cursor_image
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		EDITOR.get_node("canvas").add_child(EDITOR.CURSOR)
	func do_select(img):
		var imagepos = img.get_node("image_sprite").position
		var mousepos = img.get_global_mouse_position()
		var position_on_image = Vector2(mousepos.x - imagepos.x, mousepos.y - imagepos.y)
		var n = len(brush.brush_x) - 1
		var brush_x = brush.brush_x
		var brush_y = brush.brush_y
		var brush_a = brush.brush_a
		for e in range(0, n):
			img.selected_image.set_pixelv(
				Vector2i(brush_x[e] + position_on_image.x, brush_y[e] + position_on_image.y),
				Color(EDITOR.color[0], EDITOR.color[1], EDITOR.color[2], brush_a[e]))
		img.load_image()
	func get_options():
		var swatch_sel_sc = load("res://main_editor/swatchboard/swatch_selector.tscn")
		var swatch_sel = swatch_sel_sc.instantiate()
		var brushbox = swatch_sel.get_node("brushbox")
		brushbox.size = Vector2(50, 50)
		for brush in Nodes.brushes:
			var text = ImageTexture.create_from_image(brush.preview_image)
			brushbox.add_item(brush.name, text)
			print(brush.name)
		return([swatch_sel])

class Select:
	extends Tool
	func _init():
		name = "select"
		set_tool_image()
	func set_tool_image():
		var err = self.preview_image.load("res://theme/icons/select.png")

func append_tools_from_string(input : String, lbl : Label, prog : ProgressBar, max_prog:int = 10):
	input = input.replace("\n", "")
	var tool_splits = input.split(";")
	var n = len(tool_splits)
	var startertxt = "loading tools ("
	var endertxt = "/" + str(n) + ")"
	lbl.text = startertxt + "0" + endertxt
	var prog_add = max_prog / n
	for e in range(0, n):
		lbl.text = startertxt + str(e + 1) + endertxt
		var tooldata = tool_splits[e].split("|")
		prog.value = prog.value + prog.value
		if len(tooldata) < 2:
			continue
		var command = tooldata[0]
		var new_tool = null
		if command == "B":
			new_tool = Nodes.Brush.new()
			new_tool.set_brush_from_ps(tooldata)
			brushes.append(new_tool)
			continue
		elif command == "S":
			pass
		elif command == "BB":
			pass
		else:
			print(command)

func load_configuration(label : Label, progress : ProgressBar, anims : AnimationPlayer, popup):
	controlled = label.get_parent()
	label.text = "reading user directory"
	var new : bool = true
	if USER_DIRECTORY:
		USER_DIRECTORY.list_dir_begin()
		var file_name = USER_DIRECTORY.get_next()
		while file_name != "":
			if USER_DIRECTORY.current_is_dir():
				if file_name == "tools":
					new = false
			file_name = USER_DIRECTORY.get_next()
	if new == true:
		label.text = "welcome to pixie !"
		anims.play("new_user")
		var user_path = OS.get_user_data_dir()
		var resp = "L|pixie requires a pixie directory, we will automatically use|12;L|" + user_path + "|12;H;"
		resp = resp + "L|would this be okay?|12;"
		var buttons = "B|quit|builtin:quit_pixie;B|select directory|builtin:select_setup_dir;B|yes|builtin:setup_directory"
		popup.set_ui(resp + buttons)
		popup.visible = true
		return true
	progress.value = 15 + progress.value

# directory controls
func readdir(uri : String):
	var dir = DirAccess.open(uri)
	var dirs = []
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			dirs.append(file_name)
			file_name = dir.get_next()
	return(dirs)

class PixieNode:
	extends Control
	pass


class PixieImageNode:
	extends PixieNode
	var canvas_size : Vector2 = Vector2(0, 0)
