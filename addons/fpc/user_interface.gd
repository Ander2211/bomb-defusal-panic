extends Control

@onready var bombs_label = $BombsLabel
@onready var time_label = $TimeLabel
@onready var interaction_label = $InteraccionLabel
@onready var game_message = $GameMessage

var bombs_container :=$"../../Bombas"
var bombs := []
var total_bombs := 0

func setup_bombs(container: Node3D):
	bombs_container = container
	bombs = container.get_children()
	total_bombs = bombs.size()
	
	update_bomb_label()

	for b in bombs:
		b.bomb_defused.connect(_on_bomb_removed)
		b.bomb_exploded.connect(_on_bomb_removed)

func update_bomb_label():
	var active_count = bombs.filter(func(b): return b.is_active).size()
	bombs_label.text = "Bombas: %d | Quedan: %d" % [total_bombs, active_count]

func _process(delta):
	if bombs_container == null:
		return

	var total_time := 0.0
	for b in bombs:
		if b.is_active:
			total_time += b.time_left

	time_label.text = str(int(total_time))

func _on_bomb_removed(bomb):
	bomb.is_active = false
	update_bomb_label()
