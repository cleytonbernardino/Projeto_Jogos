extends "res://scripts/fights/base_fights.gd"

# O super desse boneco está 'meio' bugado, tem que arrumar é mais coisasa de pequeno ajuste na animação

# NOS
onready var lazer = preload("res://scenes/powers/ryanManLazer.tscn")

func _ready():
	combo_keys = {
		'runKick': [keys['baixo'], keys['punch']],
		'special1': [keys['esquerda'], keys['direita']],
		'super': [keys['direita'], keys['esquerda']],
		'jumpKick': [keys['direita'], keys['cima'], keys['esquerda']],
		'special3': [keys['block'], keys['punch']],
		'special4': [keys['baixo'], keys['baixo']]
	}

func special1() -> void:
	var obj = lazer.instance()
	get_parent().add_child(obj)
	
	obj.direction = 1 if sprite.flip_h == false else -1
	obj.global_position = point.global_position	
