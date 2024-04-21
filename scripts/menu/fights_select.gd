extends Control

# FAZER A OPÇÃO DE REMOVE JÁ SELECIONADO

var playerOneSelected: bool = false
var playerTwoSelected: bool = false

# Diretorio da cena dos lutadores
var ryanMan: String = "res://scenes/fights/ryanMan.tscn"
var baejitul: String = "res://scenes/fights/baejitul.tscn"

# Carrega o cenario
func go_to_level() -> void:
	if playerOneSelected and playerTwoSelected:
		get_tree().change_scene("res://scenes/arena/cenarios.tscn")

# Verifica e se os dois jogadores ja foram escolhidos
func select_player(dir: String) -> void:
	print(dir)
	if not playerOneSelected:
		playerOneSelected = true
		Global.playerOneDir = dir
	else:
		playerTwoSelected = true
		Global.playerTwoDir = dir
	go_to_level()

# BOTOES DE SELEÇÃO DOS PERSONAGENS
func _on_RyanMan_pressed() -> void:
	select_player(ryanMan)

func _on_Baejitul_pressed():
	select_player(baejitul)