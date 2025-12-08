extends Control



func _ready():
	var loading = preload("res://Esenas/PantallaCarga.tscn").instantiate()
	add_child(loading)
	loading.start_loading("res://Principal.tscn")


#paraboton
#func _on_jugar_pressed():
	#var loader = load("res://loading_screen.tscn").instantiate()
	#get_tree().current_scene.add_child(loader)
	#loader.start_loading("res://Escena3DGrande.tscn")
