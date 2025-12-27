extends Control
class_name UIInteract

func _ready():
	DialogSystem.registrar_ui_interact(self)
	ocultar()
	hide()

func mostrar():
	show()

func ocultar():
	hide()
