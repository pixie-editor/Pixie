extends Nodes.PixieImageNode
var dragging = false
var piximg = null
var image_name : String = ""
var active : bool = false
var selected_tools = []
# Called when the node enters the scene tree for the first time.
func _ready():
	for e in range(1, len(Nodes.tools)):
		selected_tools.append(e)

func build_region():
	var canv_sy = canvas_size.y
	var canv_sx = canvas_size.x
	var region = Image.create(canv_sx + 2, canv_sy + 2, false, Image.FORMAT_RGBA8)
	for x in range(1, canv_sx):
		region.set_pixelv(Vector2i(x, canv_sy + 1), Color(200, 0, 0, 1))
		region.set_pixelv(Vector2i(x, 0), Color(200, 0, 0, 1))
	for y in range(1, canv_sy):
		region.set_pixelv(Vector2i(0, y), Color(200, 0, 0, 1))
		region.set_pixelv(Vector2i(canv_sx + 1, y), Color(200, 0, 0, 1))
	var outer_region = $canv/outer_region
	outer_region.texture = ImageTexture.create_from_image(region)
	outer_region.position = piximg.position
	var image_size = region.get_size()

func start_from_path(path : String):
	for x in range(0, len(Nodes.tools) - 1):
		selected_tools.append(x)
	var new_piximg = load("res://main_editor/pixie_image/pixie_image.tscn")
	piximg = new_piximg.instantiate()
	piximg.load_from_path(path)
	canvas_size = piximg.image_size
	$canv/layers.add_child(piximg)

func start_from_blank(image_name : String = image_name):
	var new_piximg = load("res://main_editor/pixie_image/pixie_image.tscn")
	new_piximg.image_name = "new image"
	var piximg_cont = new_piximg.instantiate()
	piximg = piximg_cont.get_node("pixie_image")
	piximg.resize(canvas_size.x, canvas_size.y)
	piximg.load_new_image("new")
	canvas_size = piximg.image_size
	$canv/layers.add_child(piximg_cont)

func add_layer():
	if canvas_size.x == 0 && canvas_size.y == 0:
		canvas_size = piximg.image_size
	if piximg.image_size.x > canvas_size.x:
		canvas_size.x = piximg.image_size.x
	if piximg.image_size.y > canvas_size.y:
		canvas_size.x = piximg.image_size.x

func do_select():
	if not active:
		build_region()
		EDITOR.get_node("ui_animator").play("swatch_in")
		EDITOR.selected_window = self
		EDITOR.selected_nodes.append(self)
		EDITOR.get_node("canvas/swatchboard").load_tools(selected_tools)

func _process(delta):
	if dragging:
		var mouse_pos = get_viewport().get_mouse_position()
		position.x = mouse_pos.x
		position.y = mouse_pos.y

