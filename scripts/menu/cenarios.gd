extends Node2D
onready var sprite: Sprite = $Texture
onready var delay: Timer = $WinDelay

var playerOne: KinematicBody2D
var playerTwo: KinematicBody2D

var wait: bool = false

func _ready() -> void:
	randomize()
	sprite.frame = randi() % 21;
	
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
	if wait:
		return
	if playerOne.death:
		wait = true
		Global.Wins[1] += 1
		$HealthBa2r.add_win()
		playerTwo.special = "idle"
		delay.start()
		return
	elif playerTwo.death:
		wait = true
		Global.wins[0] += 1
		$HealthBar.add_win()
		playerOne.special = "idle"
		delay.start()
		return
	
	if playerOne.global_position < playerTwo.global_position:
		playerTwo.flip(-1)
		playerOne.flip(1)
	else:
		playerTwo.flip(1)
		playerOne.flip(-1)

func _on_Button_pressed():
	Global.wins = [0, 0]
	get_tree().reload_current_scene()

func _on_Button2_pressed():
	if sprite.frame == 20:
		sprite.frame = 0
		return
	sprite.frame += 1

func on_MapLimit_body_entered(body: KinematicBody2D) -> void:
	print(body.animation.current_animation)
	if "player1" in body.get_groups():
		body.global_position = $Player1.global_position
		return
	body.global_position = $Player2.global_position

func _on_WinDelay_timeout() -> void:
	if Global.wins[0] == 2 or Global.wins[1] == 2:
		print("FIM DA BATALHA")
		return
	get_tree().reload_current_scene()
