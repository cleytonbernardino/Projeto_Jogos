extends Node2D

# TEMP
onready var sprite: Sprite = $Texture
export(int, 20) var cenario = 14

var playerOne: KinematicBody2D
var playerTwo: KinematicBody2D

func _ready() -> void:
	# REMOVER DPS
	sprite.frame = cenario
	
	
	playerOne = load(Global.playerOneDir).instance()
	playerTwo = load(Global.playerTwoDir).instance()
	
	playerOne.global_position = $Player1.global_position
	playerTwo.global_position = $Player2.global_position
	
	playerOne.add_to_group('player1')
	playerTwo.add_to_group('player2')
	
	playerOne.healtBar = $HealthBar
	playerTwo.healtBar = $HealthBar2
	
	playerOne.healtBar.set_icon(playerOne.name.to_lower())
	playerTwo.healtBar.set_icon(playerTwo.name.to_lower())
	
	add_child(playerOne)
	add_child(playerTwo)

func _process(_delta: float) -> void:
	if playerOne.death:
		playerTwo.special = "run"
		return
	elif playerTwo.death:
		playerOne.special = "run"
		return
	
	if playerOne.global_position < playerTwo.global_position:
		playerTwo.flip(-1)
		playerOne.flip(1)
	else:
		playerTwo.flip(1)
		playerOne.flip(-1)


func _on_Button_pressed():
	var _trash = get_tree().change_scene("res://scenes/arena/cenarios.tscn")

func _on_Button2_pressed():
	if sprite.frame == 20:
		sprite.frame = 0
		return
	sprite.frame += 1

func on_MapLimit_body_entered(body: KinematicBody2D) -> void:
	if "player1" in body.get_groups():
		body.global_position = $Player1.global_position
		return
	body.global_position = $Player2.global_position
