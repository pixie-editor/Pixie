extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$labelcontainer/versionlabel.text = EDITOR.version


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$labelcontainer/fpslabel.text = "fps: " + str(Engine.get_frames_per_second())
	
