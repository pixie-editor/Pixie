extends Control
var loadmessage : Label

# Called when the node enters the scene tree for the first time.
func _ready():
	EDITOR.visible = false
	$anim.play("splash")
	get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	$pixie.play("default")
	loadmessage = $loading_updater

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_anim_animation_finished(anim_name):
	if anim_name == "splash":
		loadmessage.text = "loading configuration"
		var new_user = Nodes.load_configuration($loading_updater2, $ProgressBar, $anim, $pixiepopup)
		if new_user:
			return
		EDITOR.load_tools(loadmessage, $ProgressBar)
		$anim.play("splash_out")
		return
	elif anim_name == "new_user":
		if Nodes.not_setup:
			$anim.play("new_user")
		return
	EDITOR.visible = true
	EDITOR.get_node("canvas").visible = true
	EDITOR.enabled = true
	EDITOR.get_node("ui_animator").play("editor_in")
	queue_free()
