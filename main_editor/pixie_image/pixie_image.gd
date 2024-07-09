extends Node2D
var image_name : String = ""
var image_path = ""
var image_size = Vector2(0, 0)
var mode : String = "r"
var selected_image : Image
var active = false

func load_from_path(path : String = image_path):
	image_path = path
	selected_image = Image.new()
	var err = selected_image.load(image_path)
	if err != OK:
		# TODO ERROR
		print('page image load failed!')
	image_size = selected_image.get_size()
	load_image(selected_image)

func load_new_image(image_n : String = image_name):
	image_name = image_n
	selected_image = Image.new()

func load_image(image : Image = selected_image):
	image_size = image.get_size()
	$image_sprite.texture = ImageTexture.create_from_image(image)

func _on_image_sprite_gui_input(event):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			get_parent().get_parent().get_parent().do_select()
