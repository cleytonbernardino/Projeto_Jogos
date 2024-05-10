extends KinematicBody2D
class_name BaseFights

# NÃO ESQUECER DE REMOVER OS PRINTS DE DEBUG !!!
# NÃO ESQUECER DE BALACEAR OS PERSONAGENS !!!
# NÃO ESQUECER DE REVISAR AS FUNÇÃO !!! -- IMPORTANTE mesmo que seja CHATO
# REMOVER A FUNÇÃO DE CORRER SE NÃO USAR

# NOS
onready var sprite: Sprite = $Texture
onready var animation: AnimationPlayer = $Animation
onready var time: Timer = $ComboTime
onready var damage_collision: CollisionShape2D = $AttackBox.get_child(0)
onready var point: Position2D = $Point

# MOVIMENT
var velocity: Vector2 = Vector2.ZERO
var direction: float = 1
var moviment: bool = true
var is_run: bool = false
var keys: Dictionary = {
	"esquerda": "left",
	"direita": "right",
	"cima": "up",
	"baixo": "down",
	"punch": "punch",
	"block": "block"
}
var combo_keys: Dictionary

# COMBOS
var wait_time_combo: float = 0.2
var hit_count: int = 0
var sequence: Array
var special: String = ''

# Varivel de descarte, apenas para a godot não reclamar
var trash = null

# Attack
var player_ref = null
var block: bool = false
var death: bool = false
var lazer: Object

# EXPORTs
export(int) var move_speed = 20
export(float) var jump_strength = -1.3
export(float) var gravity = 1.0

export(int) var healt = 100
export(int) var mana = 0
export(int) var projectile_damage = 30

# COMBOS AND MOVIMENTOS
enum{MOVE, JUMP, ROLL, STOP}
var state = MOVE
var tween: Tween = Tween.new()

# heath bar
var healtBar: Control

func _ready() -> void:
	var name: String = self.name
	if "@" in name:
		name = self.name.split("@")[1]
	lazer = load("res://scenes/powers/%sLazer.tscn" % name)
	# Define os comando do player2
	if 'player2' in get_groups():
		keys = {
			"esquerda": "ui_left",
			"direita": "ui_right",
			"cima": "ui_up",
			"baixo": "ui_down",
			"punch": "ui_punch",
			"block": "ui_block"
		}
	combo_keys = {
		'runKick': [keys['baixo'], keys['punch']],
		'super': [keys['punch'], keys['punch'], keys['esquerda']],
		'jumpKick': [keys['direita'], keys['cima'], keys['esquerda']],
		'special1': [keys['direita'], keys['esquerda']],
		'special2': [keys['direita'], keys['punch']],
		'special3': [keys['baixo'], keys['baixo']]
	}
	
	add_child(tween)
	healtBar.DEBUG_set_max_heath(healt)
	healtBar.DEBUG_set_max_mana(mana)

func _process(delta: float) -> void:
	# Veficar se o personagem está morto e trava a sua animação para que ele fique no chão
	if death:
		animation.play("in_floor")
		trash = move_and_slide(Vector2(0, 200))
		change_collision()
		return

	if !moviment:
		state = STOP

	apply_gravity(delta)
	match state: 
		MOVE:
			move(delta)
			if is_run:
				 move(delta, true)
		JUMP:
			jump(delta)
			state = MOVE
		ROLL:
			special = 'roll'
			change_collision()
			state = MOVE
		STOP:
			pass # Isso é apenas para travar o movimento do personagem
	velocity = move_and_slide(velocity, Vector2.UP)

	if velocity.y == 0 and special == 'jumpPunch':
		on_animation_finished(special)
		return

	set_animation()

func _input(event: InputEvent) -> void:	
	if event.is_action_released("ui_run"):
		is_run = false

	if event.is_action_released(keys["block"]):
		special = ''
		block = false
		hitbox_status(true)

	if not event is InputEvent or not event.is_pressed():
		return

	elif event.is_action_pressed(keys["esquerda"]):
		state = MOVE
		sequence.push_back(keys["esquerda"])
		
	elif event.is_action_pressed(keys["direita"]):
		state = MOVE
		sequence.push_back(keys["direita"])

	elif event.is_action_pressed(keys["baixo"]):
		state = ROLL
		sequence.push_back(keys["baixo"])
		
	elif event.is_action_pressed(keys["punch"]):
		special = 'punch' if position.y > 600 else 'jumpPunch'
		sequence.push_back(keys["punch"])

	elif event.is_action_pressed(keys["block"]):
		block = true
		sequence.push_back(keys["block"])

	elif event.is_action_pressed("ui_run"):
		is_run = true

	elif Input.is_action_just_pressed(keys["cima"]) and is_on_floor():
		sequence.push_back(keys["cima"])
		state = JUMP

	time.start(wait_time_combo)

func enemy_pos() -> int:
	if sprite.flip_h:
		return -1
	else:
		return 1

func flip(sprite_direction: float) -> void:
	if sprite_direction >= 0:
		sprite.flip_h = false
		direction = -1
		if damage_collision.position.x < 0:
			damage_collision.position.x *= -1

	elif sprite_direction < 0:
		sprite.flip_h = true
		direction = 1
		if damage_collision.position.x > 0:
			damage_collision.position.x *= -1

	if sprite.flip_h and point.position.x > 0:
		point.position.x *= -1
	elif not sprite.flip_h and point.position.x < 0:
		point.position.x *= -1

func move(delta: float, run: bool = false) -> void:
	direction = Input.get_axis(keys.esquerda, keys.direita)
	var backdash_direction: String = keys['esquerda'] if enemy_pos() == 1 else keys['direita']
	var speed = move_speed * 1000

	if run:
		speed *= 2
	elif block and Input.is_action_just_pressed(backdash_direction):
		special = 'backdash'
		moviment_animation(200, 0.3, 0.0, true)
	velocity.x = direction * speed * delta

func apply_gravity(delta: float) -> void:
	velocity.y += (gravity * 1000) * delta

func jump(_delta: float) -> void:
	velocity.y = jump_strength * 500
	special = "jump"

func take_damage(damage: int) -> void:
	healt -= damage
	healtBar.damage(damage)
	special = "damage_on_ar" if velocity.y < 0 else "damage"

	$DamageCooldown.start()

	hit_count += 1
	global_position.y += -50
	global_position.x += 10 if sprite.flip_h else -10

	if special == "damage_on_ar":
		hit_count = 0
		special = "in_floor"
		moviment = false

	elif hit_count > 3:
		hit_count = 0
		special = "damage_full"
		moviment_animation(100, 0.2, 0.0, true)
		moviment = false

	if healt <= 0:
		death = true

func set_animation() -> void:
	var anim_name: String = 'idle' if !block else 'block'

	if special == "in_floor" and velocity.y == 0:
		special = ""
		state = MOVE
		moviment = true

	if special != '':
		anim_name = special
	elif velocity.y != 0 and 'damage' in special:
		anim_name = 'jump'
	elif velocity.x != 0:
		anim_name = 'walk'
		if is_run:
			anim_name = 'run'

	animation.play(anim_name)

# O NOME DISSO NEM FAZ SENTIDO ARRUMAR UM NOME MELHOR KKK
# Tenho que estudar melhor esse metodo tween
func moviment_animation(distance: float, duration: float, y_moviment: float = 0.0, invert: bool = false) -> void:
	"""
		Faz que animações de movimento por impacto, ou esquiva seja animadas de forma mais fluida
	"""
	var pos: int = enemy_pos() if !invert else (enemy_pos() * -1)
	var knockback_vector: Vector2 = Vector2(pos, y_moviment).normalized() * distance

	trash = tween.interpolate_property(
		self, "position", position, position + knockback_vector, duration,
		tween.TRANS_LINEAR, tween.EASE_IN_OUT
	)
	trash = tween.start()

func check_sequence(combo: Array) -> void:
	for moviments in combo_keys.keys():
		if combo == combo_keys[moviments]:
			var cost: int = Global.special_cust.get(moviments, 0)
			if mana < (cost * -1):
				return
			mana += cost
			healtBar.set_mana(mana)
			special = moviments

# Não esquecer de remover o dano
func basic_attack(damage: float = 0.0) -> void:
	if not player_ref:
		return
	if not damage:
		damage = Global.attack_damage.get(special, 0)
	player_ref.take_damage(damage)
	$HitCount.start()
	mana += Global.special_cust.get(special, 0)
	healtBar.set_mana(mana)

func atack_move() -> void:
	if special == "runKick":
		moviment_animation(200, 0.3)
		return
	moviment_animation(400, 0.6, 0.4)

func projectile() -> void:
	print(self.name)
	var obj = lazer.instance()
	get_parent().add_child(obj)
	
	var direction: int = 1 if sprite.flip_h == false else -1
	obj.damage = projectile_damage
	obj.direction = direction
	obj.rotate(direction)
	obj.global_position = point.global_position


func change_collision(colision_state: bool = false) -> void:
	self.set_collision_layer_bit(1, colision_state)
	self.set_collision_layer_bit(3, false if colision_state else true)
	self.set_collision_mask_bit(1, colision_state)

# *** MELHORAR ESTE METODO ***
func impact() -> void:
	if not player_ref:
		return

	if sprite.flip_h:
		player_ref.global_position.x -= 100
	else:
		player_ref.global_position.x += 100

	player_ref.special = 'damage_full'

func hitbox_status(status: bool = true):
	$HitBox.monitorable = status

func on_ComboTime_timeout() -> void:
	check_sequence(sequence)
	sequence.clear()

func on_HitCount_timeout() -> void:
	hit_count = 0

func on_DamageCooldown_timeout() -> void:
	moviment = true
	state = MOVE
	special = ""

func on_HitBox_area_entered(area:Area2D) -> void:
	var parent = area.get_parent()
	if parent.get_groups() == get_groups():
		return

	player_ref = parent
	if special == 'jumpPunch':
		basic_attack(30)
		on_animation_finished(special)
	elif special == "runKick":
		basic_attack(20)
		impact()
		on_animation_finished(special)

func on_HitBox_area_exited(_area: Area2D) -> void:
	player_ref = null
	state = MOVE

func on_animation_finished(_anim_name: String) -> void:
	if death:
		return
	
	if special == "damage_full" and velocity.y >= 50:
		animation.play("in_floor")
		return

	special = ''
	change_collision(true)
