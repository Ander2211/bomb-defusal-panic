extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _process(delta):
	if not $VisibleOnScreenNotifier3D.is_on_screen():
		return
