extends "res://scripts/fights/base_fights.gd"

# NOS
onready var ball = preload("res://scenes/powers/CTonaldoBall.tscn")

func _ready():
	combo_keys = {
		'runKick': [keys['baixo'], keys['punch']],
		'super': [keys['direita'], keys['esquerda']],
		'jumpKick': [keys['direita'], keys['cima'], keys['esquerda']], # BUGADO TENHO QUE CORRIGIR, AO USAR O PERSONAGEM NÃO DA MAIS DANO
		'special1': [keys['esquerda'], keys['direita']],
		'special2': [keys['baixo'], keys['baixo']],
		'special3': [keys['direita'], keys['punch']]
	}

func projectile() -> void:
	var obj = ball.instance()
	get_parent().add_child(obj)
	
	var direction: int = 1 if sprite.flip_h == false else -1
	obj.direction = direction
	obj.rotate(direction)
	obj.global_position = point.global_position
