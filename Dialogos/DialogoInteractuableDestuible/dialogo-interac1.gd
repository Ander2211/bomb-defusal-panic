extends Area3D

@onready var globals = get_node("/root/Variableglobal")


func _process(delta: float) -> void:
	# Detectar si hay cuerpos/áreas dentro del área
	if has_overlapping_bodies() or has_overlapping_areas():
		
		# Solo interactúa si no hay diálogo activo
		if globals.game_state == 0 and Input.is_action_just_pressed("interact"):
			
			# Definir el diálogo
			globals.dialog = [
				"Dialogo",
                "Destruble"
			]

			# Activar sistema de diálogo
			globals.new_dialog = true
			globals.text_show = true
			globals.game_state = 1   # Bloquea movimiento o acciones del jugador

			# Destruir este objeto después de usarlo
			queue_free()
