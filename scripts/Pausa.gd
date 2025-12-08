extends Control

func _ready():
	# Ocultar el menú de pausa completo al iniciar
	$ColorRect.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED  # capturar mouse al comenzar


func _input(event):
	# Detectar ESC (ui_cancel)
	if event.is_action_pressed("ui_cancel"):
		toggle_pausa()


func toggle_pausa():
	# Cambiar estado de pausa
	get_tree().paused = not get_tree().paused
	
	# Mostrar u ocultar el menú
	$ColorRect.visible = get_tree().paused
	
	# Manejo del mouse
	if get_tree().paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_reanudar_pressed() -> void:
	# Si el juego está pausado, reanudar
	if get_tree().paused:
		toggle_pausa()


# Menú Ajustes
#func _on_ajustes_pressed() -> void:
#	get_tree().change_scene_to_file("res://scenes/GUI/VistaAjustes.tscn")


func _on_salir_pressed() -> void:
	get_tree().quit()
