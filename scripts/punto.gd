extends CharacterBody2D

@export var speed := 200
signal golpe_pared 

var move := true  # Permite o bloquea el movimiento

var constant_direction = Vector2.ZERO

var trail_points = []
var max_trail_points = 1050
var trail_timer = 0.0
var trail_interval = 0.002


func _ready():
	set_process(true)


func _physics_process(delta):
	if not move:
		return  # Punto congelado, no se mueve

	# Movimiento del jugador
	if Input.is_action_just_pressed("ui_left"):
		constant_direction = Vector2.LEFT
	elif Input.is_action_just_pressed("ui_right"):
		constant_direction = Vector2.RIGHT
	elif Input.is_action_just_pressed("ui_up"):
		constant_direction = Vector2.UP
	elif Input.is_action_just_pressed("ui_down"):
		constant_direction = Vector2.DOWN
	
	velocity = constant_direction * speed
	move_and_slide()
	
	# Rastro
	trail_timer += delta
	if trail_timer >= trail_interval:
		trail_timer = 0.0
		trail_points.append(global_position)

		if trail_points.size() > max_trail_points:
			trail_points.remove_at(0)

	queue_redraw()

	# Detección de colisión
	for i in range(get_slide_collision_count()):
		var col = get_slide_collision(i)
		if col.get_collider() is StaticBody2D:
			emit_signal("golpe_pared")
			return


func _draw():
	if trail_points.size() > 1:
		for i in range(1, trail_points.size()):
			var start_pos = to_local(trail_points[i-1])
			var end_pos = to_local(trail_points[i])
			var alpha = float(i) / trail_points.size()
			draw_line(start_pos, end_pos, Color(1, 1, 1, alpha), 10.0)


# --- FUNCIONES NUEVAS PARA EL LABERINTO ---
func freeze_point():
	move = false
	velocity = Vector2.ZERO
	constant_direction = Vector2.ZERO


func unfreeze_point():
	move = true


func clear_trail():
	trail_points.clear()
	queue_redraw()
