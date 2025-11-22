extends Node3D
class_name Bomb

signal bomb_defused
signal bomb_exploded

@export var time_limit: float = 120.0
@export var minigame_scene: PackedScene

var current_time: float
var is_active: bool = false
var player_in_range: bool = false
var minigame_instance: Node

@onready var bomb_light: OmniLight3D = $OmniLight3D
@onready var interaction_area: Area3D = $Area3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var explosion_player: AudioStreamPlayer3D = $AudioStreamPlayer3D_Explosion
@onready var explosion_fx := $Explosion

func _ready():
	current_time = time_limit
	setup_bomb()
	activate_bomb()


func setup_bomb():
	var beep_sound = load("res://Assets/beep.ogg")
	if beep_sound:
		if beep_sound is AudioStreamWAV:
			beep_sound.loop_mode = AudioStreamWAV.LOOP_FORWARD
		elif beep_sound is AudioStreamOggVorbis:
			beep_sound.loop = true
	else:
		print("ERROR: No se pudo cargar res://assets/beep.ogg")

	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)


func _process(delta):
	if not is_active:
		return
		
	current_time -= delta
	
	if current_time <= 0:
		explode()


func activate_bomb():
	is_active = true
	print("¡Bomba activada! Tiempo:", time_limit)

	if animation_player.has_animation("parpadeo"):
		animation_player.play("parpadeo")


func _on_body_entered(body):
	if body.is_in_group("Player"):
		player_in_range = true


func _on_body_exited(body):
	if body.is_in_group("Player"):
		player_in_range = false


func _input(event):
	if (player_in_range and event.is_action_pressed("interact") 
		and is_active and minigame_instance == null):
		start_minigame()


func start_minigame():
	print("Iniciando minijuego...")

	if minigame_scene:
		var player = get_tree().get_first_node_in_group("Player")
		if player and player.has_method("disable_movement"):
			player.disable_movement()

		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

		minigame_instance = minigame_scene.instantiate()
		get_tree().current_scene.add_child(minigame_instance)

		minigame_instance.minigame_success.connect(_on_minigame_success)
		minigame_instance.minigame_failed.connect(_on_minigame_failed)
	else:
		print("ERROR: No hay minigame_scene asignado")


func _on_minigame_success():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	defuse_bomb()


func _on_minigame_failed():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("enable_movement"):
		player.enable_movement()
	
	cleanup_minigame()


func defuse_bomb():
	print("¡Bomba desactivada!")
	is_active = false
	
	animation_player.stop()
	$AudioStreamPlayer3D.stop()

	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("enable_movement"):
		player.enable_movement()

	bomb_light.light_color = Color.GREEN
	bomb_light.light_energy = 3.0
	
	cleanup_minigame()
	bomb_defused.emit()


# -----------------------------------------
# 💥 FUNCIÓN DE EXPLOSIÓN COMPLETA
# -----------------------------------------
func explode():
	print("💥 ¡BOOM! La bomba explotó!")
	is_active = false

	animation_player.stop()
	$AudioStreamPlayer3D.stop()

	# 🔥 Reproducir sonido de explosión
	if explosion_player:
		explosion_player.play()

	# 💨 Mostrar animación / partículas de explosión
	if explosion_fx:
		for p in explosion_fx.get_children():
			if p is GPUParticles3D:
				p.restart()
				p.emitting = true

	# 💡 Apagar luz de la bomba
	bomb_light.light_energy = 0

	# (Opcional) Empujar al jugador:
	# var player = get_tree().get_first_node_in_group("Player")
	# if player:
	#     var dir = (player.global_position - global_position).normalized()
	#     player.apply_impulse(dir * 50)

	# Reactivar movimiento del jugador si estaba en minijuego
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_method("enable_movement"):
		player.enable_movement()

	bomb_exploded.emit()


func cleanup_minigame():
	if minigame_instance:
		minigame_instance.queue_free()
		minigame_instance = null
