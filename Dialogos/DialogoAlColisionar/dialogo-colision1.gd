extends Area3D

@onready var globals = get_node("/root/Variableglobal")


func _ready():
	# Conectar la señal de colisión
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	# Solo activar si el diálogo no está activo
	if globals.game_state == 0 and body.name == "Player":

		globals.dialog = [
			"¡Bienvenido al bosque!",
            "Aquí encontrarás tesoros ocultos."
		]
		
		globals.new_dialog = true
		globals.text_show = true
		globals.game_state = 1  # bloquea movimiento del jugador

		queue_free()  # destruir área si solo debe ejecutarse una vez
