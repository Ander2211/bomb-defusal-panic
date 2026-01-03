extends Node

signal bomba_desactivada(bomba)
signal bomba_explodida(bomba)

var bombas_activas: int = 0

func registrar_bomba():
	bombas_activas += 1
	print("Bomba registrada. Total: ", bombas_activas)

func desactivar_bomba():
	bombas_activas -= 1
	print("Bomba desactivada. Quedan: ", bombas_activas)
