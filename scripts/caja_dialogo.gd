extends Control

@onready var globals = get_node("/root/Variableglobal")

var dialog_index: int = 0
var finished: bool = false
@onready var anim = $AnimationPlayer


func _ready() -> void:
	load_dialog()
	anim.play("press")


func _process(delta: float) -> void:
	# Mostrar / ocultar el control según la variable global
	visible = globals.text_show

	# Si se inicia un nuevo diálogo
	if globals.new_dialog:
		dialog_index = 0
		load_dialog()
		globals.new_dialog = false

	# Avanzar diálogo cuando se presiona el botón
	if Input.is_action_just_pressed("interact") and globals.game_state == 1:
		load_dialog()


func load_dialog() -> void:
	var dialog = globals.dialog

	if dialog_index < dialog.size():
		# Godot 4 ya no usa bbcode_text (es RichTextLabel.text o .set_bbcode())
		$RichTextLabel.text = dialog[dialog_index]
	else:
		globals.text_show = false
		globals.game_state = 0
		dialog_index = 0
		return

	dialog_index += 1
