extends Node3D

func _ready() -> void:
	pass

func _process(delta):
	if not $VisibleOnScreenNotifier3D.is_on_screen():
		return
