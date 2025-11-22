extends Node3D

class_name GameManager

# Señales
signal game_won
signal game_lost

# Variables exportadas
@export var bomb_scene: PackedScene
@export var minigame_scene: PackedScene
@export var spawn_area: Area3D
@export var total_time: float = 300.0  # 5 minutos
@export var bomb_count: int = 3

# Variables internas
var current_time: float
var bombs_remaining: int
var active_bombs: Array = []
var game_active: bool = true

@onready var ui: Control = $UserInterface

func _ready():
	start_game()

func start_game():
	current_time = total_time
	bombs_remaining = bomb_count
	game_active = true
	
	# Generar bombas
	spawn_bombs()
	
	# Actualizar UI
	update_ui()

func _process(delta):
	if not game_active:
		return
		
	current_time -= delta
	
	if current_time <= 0:
		game_over()
	
	update_ui()

func spawn_bombs():
	for i in range(bomb_count):
		var bomb = bomb_scene.instantiate()
		add_child(bomb)
		
		# Asignar minijuego
		bomb.minigame_scene = minigame_scene
		
		# Posición aleatoria dentro del área
		bomb.global_position = get_random_position_in_area()
		
		# Conectar señales
		bomb.bomb_defused.connect(_on_bomb_defused.bind(bomb))
		bomb.bomb_exploded.connect(_on_bomb_exploded)
		
		active_bombs.append(bomb)
		
		# Activar la bomba después de un pequeño delay
		await get_tree().create_timer(0.5).timeout
		bomb.activate_bomb()

func get_random_position_in_area() -> Vector3:
	if not spawn_area:
		return Vector3.ZERO
		
	var shape = spawn_area.get_node("CollisionShape3D").shape
	if shape is BoxShape3D:
		var extents = shape.size / 2.0
		var area_pos = spawn_area.global_position
		
		var random_x = randf_range(-extents.x, extents.x)
		var random_y = randf_range(-extents.y, extents.y)
		var random_z = randf_range(-extents.z, extents.z)
		
		return area_pos + Vector3(random_x, random_y, random_z)
	
	return spawn_area.global_position

func _on_bomb_defused(bomb: Bomb):
	bombs_remaining -= 1
	active_bombs.erase(bomb)
	
	print("Bomba desactivada. Quedan: ", bombs_remaining)
	
	if bombs_remaining <= 0:
		victory()
	
	update_ui()

func _on_bomb_exploded():
	game_over()

func victory():
	game_active = false
	print("¡Todas las bombas desactivadas! ¡Victoria!")
	game_won.emit()
	
	# Mostrar mensaje de victoria en UI
	if ui and ui.has_method("show_victory"):
		ui.show_victory()

func game_over():
	game_active = false
	print("¡Game Over!")
	game_lost.emit()
	
	# Explotar todas las bombas restantes
	for bomb in active_bombs:
		if bomb.is_active:
			bomb.explode()
	
	# Mostrar mensaje de derrota en UI
	if ui and ui.has_method("show_game_over"):
		ui.show_game_over()

func update_ui():
	if ui and ui.has_method("update_game_info"):
		ui.update_game_info(current_time, bombs_remaining)
