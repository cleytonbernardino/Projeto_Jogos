extends Control
class_name HealthBar

onready var health: ProgressBar = $HealthBar
onready var mana: ProgressBar = $ManaBar
onready var model: TextureRect = $PlayerIcon
onready var win1: ColorRect = $Win1
onready var win2: ColorRect = $Win2

var icon

func _ready() -> void:
	add_win()

# MELHOR ISSO
func set_icon(fight_name: String) -> void:
	var path: String = "res://assets/fights/icon/{0}.png".format([fight_name])

	icon = load(path)
	model.texture = icon

func add_win() -> void:
	var current_wins:int = Global.wins[0] if self.name == "HealthBar" else Global.wins[1]
	if current_wins == 1:
		win1.color = "#5260f2"
	elif current_wins == 2:
		win1.color = "#5260f2"
		win2.color = "#5260f2"

func DEBUG_set_max_heath(heath_value: int) -> void:
	health.max_value = heath_value
	health.value = heath_value

func DEBUG_set_max_mana(mana_value: int) -> void:
	if mana_value <= 0:
		mana.max_value = 100
		mana.value = 0
		return

	mana.max_value = mana_value
	mana.value = mana_value

func damage(value: int) -> void:
	health.value -= value

func set_mana(value: int) -> void:
	mana.value = value
