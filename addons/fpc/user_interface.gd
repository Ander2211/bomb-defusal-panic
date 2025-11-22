extends Control



@onready var time_label: Label = $TimeLabel
@onready var bombs_label: Label = $BombsLabel
@onready var game_message: Label = $GameMessage

func _ready():
	# Ocultar mensaje de juego al inicio
	if game_message:
		game_message.visible = false

func update_game_info(time: float, bombs: int):
	# Actualizar tiempo (formato MM:SS)
	var minutes = int(time) / 60
	var seconds = int(time) % 60
	time_label.text = "Tiempo: %02d:%02d" % [minutes, seconds]
	
	# Actualizar contador de bombas
	bombs_label.text = "Bombas: %d" % bombs

func show_victory():
	if game_message:
		game_message.text = "¡VICTORIA!\nTodas las bombas desactivadas"
		game_message.visible = true

func show_game_over():
	if game_message:
		game_message.text = "¡GAME OVER!\nLa bomba ha explotado"
		game_message.visible = true
