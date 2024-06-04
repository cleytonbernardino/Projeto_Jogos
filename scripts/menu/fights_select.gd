extends Control

onready var r_Animation: AnimationPlayer = $Animation
onready var l_Animation: AnimationPlayer = $Animation2

# THEMES
var default: Theme = load("res://assets/themes/FightSelectButton.tres")
var select_themeP1: Theme = load("res://assets/themes/FightSelectButtonP1.tres")
var select_themeP2: Theme = load("res://assets/themes/FightSelectButtonP2.tres")

var button_order: Dictionary = {
	0: "Aren",
	1: "Badman",
	2: "Baejitul",
	3: "CapAfrica",
	4: "CTonaldo",
	5: "RyanMan",
	6: "Sonogong",
	7: "Sutoman"
}

var current: Array = [0, 4]

onready var p1: Button = get_node(button_order[current[0]])
onready var p2: Button = get_node(button_order[current[1]])

func _ready() -> void:
	p1.theme = select_themeP1
	p2.theme = select_themeP2
	Global.playerOneDir = "res://scenes/fights/Aren.tscn"
	Global.playerTwoDir = "res://scenes/fights/RyanMan.tscn"

func _physics_process(_delta: float) -> void:
	if current[0] == current[1]:
		return
	
	if p1.theme == default:
		p1.theme = select_themeP1
		
	if p2.theme == default:
		p2.theme = select_themeP2

func _input(event):
	if Global.playerOneDir == "":
		if event.is_action_pressed("right") and current[0] < 7:
			current[0] += 1
			p1.theme = default
			p1 = get_node(button_order[current[0]])
			p1.theme = select_themeP1
		elif event.is_action_pressed("left") and current[0] > 0:
			current[0] -= 1
			p1.theme = default
			p1 = get_node(button_order[current[0]])
			p1.theme = select_themeP1
		elif event.is_action_pressed("punch"):
			Global.playerOneDir = Global.fights[current[0]]
		r_Animation.play(button_order[current[0]])

	if Global.playerTwoDir == "":
		if event.is_action_pressed("ui_right") and current[1] < 7:
			current[1] += 1
			p2.theme = default
			p2 = get_node(button_order[current[1]])
			p2.theme = select_themeP2
		elif event.is_action_pressed("ui_left") and current[1] > 0:
			current[1] -= 1
			p2.theme = default
			p2 = get_node(button_order[current[1]])
			p2.theme = select_themeP2
		elif event.is_action_pressed("ui_punch"):
			Global.playerTwoDir = Global.fights[current[1]]
		l_Animation.play(button_order[current[1]])

	if event.is_action_pressed("block"):
		Global.playerOneDir = ""

	if event.is_action_pressed("ui_block"):
		Global.playerTwoDir = ""

	if event.is_action_pressed("ui_accept"):
		_on_Jogar_pressed()

func _on_Jogar_pressed() -> void:
	if Global.playerOneDir != "" and Global.playerTwoDir != "":
		get_tree().change_scene("res://scenes/arena/cenarios.tscn")
	else:
		$ErroLabel.visible = true
