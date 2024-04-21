extends Control
class_name HealthBar

onready var health: ProgressBar = $HealthBar
onready var mana: ProgressBar = $ManaBar
onready var icon: TextureRect = $PlayerIcon

# MELHOR ISSO
func set_icon(fight_name: String) -> void:
	var path: String = "res://assets/fights/icon/{0}.png".format([fight_name])
	var texture: Texture = ImageTexture.new()

	texture.load(path)
	icon.set_texture(texture)

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
