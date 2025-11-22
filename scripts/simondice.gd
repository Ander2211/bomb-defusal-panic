extends CanvasLayer

signal minigame_success
signal minigame_failed

var sequence: Array = []
var player_sequence: Array = []
var current_round: int = 0
var max_rounds: int = 3
var is_playing_sequence: bool = false
var can_click: bool = false
var player_node: Node


# Texturas para los colores (debes crear estas imágenes o usar las que ya tienes)
var color_textures = {
	0: preload("res://Assets/colores/rojo.png"),  # Rojo
	1: preload("res://Assets/colores/verde.png"), # Verde
	2: preload("res://Assets/colores/azul.png"),  # Azul
	3: preload("res://Assets/colores/amarillo.png") # Amarillo
}

# Nombres de los colores para debug
var color_names = ["ROJO", "VERDE", "AZUL", "AMARILLO"]

@onready var buttons: Array = [
	$CenterContainer/Panel/VBoxContainer/GridContainer/Rojo,
	$CenterContainer/Panel/VBoxContainer/GridContainer/Verde,
	$CenterContainer/Panel/VBoxContainer/GridContainer2/Azul,
	$CenterContainer/Panel/VBoxContainer/GridContainer2/Amarillo
]

@onready var instruction_label: Label = $CenterContainer/Panel/VBoxContainer/Instructions
@onready var round_label: Label = $ronda
@onready var sequence_display: GridContainer = $CenterContainer/Panel/VBoxContainer/SequenceDisplay

func _ready():
	
	$CenterContainer/Panel/VBoxContainer/GridContainer/Rojo.pressed.connect(_on_button_pressed.bind(0))
	$CenterContainer/Panel/VBoxContainer/GridContainer/Verde.pressed.connect(_on_button_pressed.bind(1))
	$CenterContainer/Panel/VBoxContainer/GridContainer2/Azul.pressed.connect(_on_button_pressed.bind(2))
	$CenterContainer/Panel/VBoxContainer/GridContainer2/Amarillo.pressed.connect(_on_button_pressed.bind(3))
	# Configurar botones
	for i in range(buttons.size()):
		if buttons[i] is BaseButton:
			buttons[i].pressed.connect(_on_button_pressed.bind(i))
	
	# Crear contenedor para mostrar imágenes de secuencia
	setup_sequence_display()
	#setup_node_references()
	#setup_button_connections()
	
	# Guardar referencia al jugador
	player_node = get_tree().get_first_node_in_group("Player")
	
	start_game()

func setup_sequence_display():
	# Si no existe el contenedor, lo creamos dinámicamente
	if not has_node("CenterContainer/Panel/VBoxContainer/SequenceDisplay"):
		var new_display = GridContainer.new()
		new_display.name = "SequenceDisplay"
		new_display.columns = 4
		$CenterContainer/Panel/VBoxContainer.add_child(new_display)
		$CenterContainer/Panel/VBoxContainer.move_child(new_display, 2) # Después de Instructions

func start_game():
	sequence.clear()
	player_sequence.clear()
	current_round = 0
	start_new_round()

func start_new_round():
	current_round += 1
	round_label.text = "Ronda " + str(current_round) + "/" + str(max_rounds)
	player_sequence.clear()
	add_to_sequence()
	
	# Mostrar instrucciones con imágenes de la secuencia
	show_sequence_with_images()
	can_click = false
	
	await get_tree().create_timer(2.0).timeout
	play_sequence()

func add_to_sequence():
	# Añadir un nuevo color aleatorio a la secuencia
	var random_color = randi() % 4
	sequence.append(random_color)
	print("Secuencia actual: ", sequence)

func show_sequence_with_images():
	instruction_label.text = "MEMORIZA LA SECUENCIA:"
	
	# Limpiar display anterior
	clear_sequence_display()
	
	# Mostrar imágenes de la secuencia actual
	for color_index in sequence:
		add_color_image_to_display(color_index)

func clear_sequence_display():
	var display = $CenterContainer/Panel/VBoxContainer/SequenceDisplay
	for child in display.get_children():
		child.queue_free()

func add_color_image_to_display(color_index: int):
	var display = $CenterContainer/Panel/VBoxContainer/SequenceDisplay
	var texture_rect = TextureRect.new()
	
	if color_textures.has(color_index):
		texture_rect.texture = color_textures[color_index]
	else:
		# Fallback: crear un color sólido
		texture_rect.texture = create_solid_color_texture(get_color_from_index(color_index))
	
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	texture_rect.custom_minimum_size = Vector2(50, 50)
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	display.add_child(texture_rect)

func get_color_from_index(index: int) -> Color:
	match index:
		0: return Color.RED
		1: return Color.GREEN
		2: return Color.BLUE
		3: return Color.YELLOW
		_: return Color.WHITE

func create_solid_color_texture(color: Color) -> ImageTexture:
	var image = Image.create(50, 50, false, Image.FORMAT_RGBA8)
	image.fill(color)
	var texture = ImageTexture.create_from_image(image)
	return texture

func play_sequence():
	is_playing_sequence = true
	instruction_label.text = "¡OBSERVA LA SECUENCIA!"
	
	# Mostrar cada color de la secuencia con delay
	for i in range(sequence.size()):
		var button_index = sequence[i]
		await highlight_button(button_index)
		await get_tree().create_timer(0.5).timeout
	
	is_playing_sequence = false
	can_click = true
	show_player_turn_instructions()

func show_player_turn_instructions():
	instruction_label.text = "¡TU TURNO! REPITE LA SECUENCIA"
	
	# Mostrar la secuencia que debe repetir
	clear_sequence_display()
	for color_index in sequence:
		add_color_image_to_display(color_index)

func highlight_button(button_index: int):
	var button = buttons[button_index]
	var original_modulate = button.modulate
	
	# Resaltar el botón
	button.modulate = Color.WHITE
	
	await get_tree().create_timer(0.8).timeout
	
	# Restaurar color original
	button.modulate = original_modulate

func _on_button_pressed(button_index: int):
	if not can_click or is_playing_sequence:
		return
	
	# Resaltar el botón que presionó el jugador
	await highlight_button(button_index)
	
	player_sequence.append(button_index)
	
	# Mostrar progreso del jugador
	instruction_label.text = "Progreso: " + str(player_sequence.size()) + "/" + str(sequence.size())
	
	# Verificar si cometió un error
	for i in range(player_sequence.size()):
		if player_sequence[i] != sequence[i]:
			instruction_label.text = "¡ERROR! PRESIONASTE EL COLOR INCORRECTO"
			await get_tree().create_timer(2.0).timeout
			game_over()
			return
	
	# Verificar si completó la secuencia correctamente
	if player_sequence.size() == sequence.size():
		if current_round >= max_rounds:
			victory()
		else:
			instruction_label.text = "¡RONDA " + str(current_round) + " COMPLETADA!"
			await get_tree().create_timer(1.5).timeout
			start_new_round()

func victory():
	instruction_label.text = "¡TODAS LAS RONDAS COMPLETADAS!\n¡BOMBA DESACTIVADA!"
	await get_tree().create_timer(2.0).timeout
	
	# Asegurarse de que el jugador se reactive
	if player_node and player_node.has_method("enable_movement"):
		player_node.enable_movement()
	
	minigame_success.emit()
	queue_free()

func game_over():
	instruction_label.text = "¡FALLASTE!\nLA BOMBA SIGUE ACTIVA"
	can_click = false
	await get_tree().create_timer(3.0).timeout
	
	# Asegurarse de que el jugador se reactive incluso al fallar
	if player_node and player_node.has_method("enable_movement"):
		player_node.enable_movement()
	
	minigame_failed.emit()
	queue_free()
	
func _exit_tree():
	# Si el minijuego se cierra de cualquier manera, reactivar al jugador
	if player_node and player_node.has_method("enable_movement"):
		player_node.enable_movement()
