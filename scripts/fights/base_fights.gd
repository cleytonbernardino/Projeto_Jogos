extends KinematicBody2D
class_name BaseFights

# NOS
onready var sprite: Sprite = $Texture
onready var animation: AnimationPlayer = $Animation
onready var time: Timer = $ComboTime
onready var block_time: Timer = $BlockMaxTime
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

# Discard variable, just so godot doesn't complain
var ignore = null

# Attack
var player_ref = null
var block: bool = false
var death: bool = false
var lazer: Object
var time_block: float = 2.5

# EXPORTS
export(int) var move_speed = 30
export(float) var jump_strength = -1.3
export(float) var gravity = 1.0

export(int) var healt = 1000
export(int) var max_mana = 100
export(int) var mana = 0

# COMBOS AND MOVIMENTOS
enum{MOVE, JUMP, ROLL, STOP}
var state = MOVE
var tween: Tween = Tween.new()

# heath bar
var healtBar: Control

func _ready() -> void:
	block_time.wait_time = time_block
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
		'jumpKick': [keys['direita'], keys['cima'], keys['esquerda']],
		'special1': [keys['direita'], keys['esquerda']],
		'special2': [keys['block'], keys['punch']],
		'special3': [keys['baixo'], keys['baixo']],
		'super': [keys['punch'], keys['baixo']],
	}
	
	healtBar.set_health(healt)
	healtBar.define_max_mana(max_mana)
	healtBar.set_mana(mana)
	add_child(tween)

func _process(delta: float) -> void:
	# Veficar se o personagem está morto e trava a sua animação para que ele fique no chão
	if death:
		animation.play("in_floor")
		ignore = move_and_slide(Vector2(0, 200))
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
		special = 'punch' if position.y > 400 else 'jumpPunch'
		sequence.push_back(keys["punch"])

	elif event.is_action_pressed(keys["block"]):
		block = true
		block_time.start()
		sequence.push_back(keys["block"])

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
		if (self.global_position.x + 200) >= 1400 or (self.global_position.x - 200) <= 0:
			return
		special = 'backdash'
		animate_repulsion_movement(200, 0.3, 0.0, true)
	velocity.x = direction * speed * delta

func apply_gravity(delta: float) -> void:
	velocity.y += (gravity * 1000) * delta

func jump(_delta: float) -> void:
	velocity.y = jump_strength * 500
	special = "jump"

func take_damage(damage: int) -> void:
	healt -= damage
	healtBar.damage(damage)
	special = "damage"

	$DamageCooldown.start()

	hit_count += 1
	global_position.y += -50
	if (self.global_position.x + 10) < 1380 or (self.global_position.x - 10) > 10:
		global_position.x += 10 if sprite.flip_h else -10
		
	if velocity.y < 0:
		hit_count = 0
		special = "damage_on_ar"
		moviment = false

	elif special == "damage_on_ar":
		hit_count = 0
		special = "in_floor"
		moviment = false

	elif hit_count > 3:
		hit_count = 0
		special = "damage_full"
		moviment = false
		if (self.global_position.x + 100) >= 1300 or (self.global_position.x - 100) <= 0:
			return
		animate_repulsion_movement(100, 0.2, 0.0, true)

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

func animate_repulsion_movement(distance: float, duration: float, y_moviment: float = 0.0, invert: bool = false) -> void:
	var pos: int = enemy_pos() if !invert else (enemy_pos() * -1)
	var knockback_vector: Vector2 = Vector2(pos, y_moviment).normalized() * distance

	ignore = tween.interpolate_property(
		self, "position", position, position + knockback_vector, duration,
		tween.TRANS_LINEAR, tween.EASE_IN_OUT
	)
	ignore = tween.start()

func check_sequence(combo: Array) -> void:
	for moviments in combo_keys.keys():
		if combo == combo_keys[moviments]:
			var cost: int = Global.special_cust.get(moviments, 0)
			if mana < (cost * -1):
				return
			mana += cost
			healtBar.set_mana(mana)
			special = moviments

func basic_attack(damage: float = 0.0) -> void:
	if not player_ref:
		return
	if not damage:
		damage = Global.attack_damage.get(special, 0)
	player_ref.take_damage(damage)
	$HitCount.start()
	var calc_mana = Global.special_cust.get(special, 0)
	if calc_mana + mana > max_mana:
		return
	mana += Global.special_cust.get(special, 0)
	healtBar.set_mana(mana)

func atack_move() -> void:
	if special == "runKick":
		animate_repulsion_movement(200, 0.3)
		return
	elif special == "special2":
		animate_repulsion_movement(300, 0.3)
		return
	animate_repulsion_movement(400, 0.6, 0.4)

func projectile() -> void:
	var obj = lazer.instance()
	get_parent().add_child(obj)
	
	direction = 1 if sprite.flip_h == false else -1
	obj.damage = Global.attack_damage.get("projectile", 50)
	obj.direction = direction
	obj.rotate(direction)
	if special == 'special3':
		obj.change_animation('kame_ini')
		obj.damage = Global.attack_damage.get('kame_damage', 20)
	
	obj.global_position = point.global_position


func change_collision(colision_state: bool = false) -> void:
	self.set_collision_layer_bit(1, colision_state)
	self.set_collision_layer_bit(3, false if colision_state else true)
	self.set_collision_mask_bit(1, colision_state)

func impact() -> void:
	if not player_ref:
		return
	
	if player_ref.global_position.x >= 1235 or player_ref.global_position.x == 33:
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

func _on_BlockMaxTime_timeout() -> void:
	Input.action_release(keys["block"])
	special = ""
	block = false
	hitbox_status(true)
	state = MOVE

func on_HitBox_area_exited(area: Area2D) -> void:
	if area == $HitBox:
		return
	player_ref = null
	state = MOVE

func on_HitBox_area_entered(area:Area2D) -> void:
	var parent = area.get_parent()
	if parent.get_groups() == get_groups():
		return

	player_ref = parent
	if special == 'jumpPunch':
		basic_attack(30)
		on_animation_finished(special)
	elif special == "runKick" or special == "special2":
		basic_attack(Global.attack_damage.get(special, 20))
		impact()
		on_animation_finished(special)

func on_animation_finished(_anim_name: String) -> void:
	if death:
		return
	
	if special == "damage_full" and velocity.y >= 50:
		animation.play("in_floor")
		return

	special = ''
	change_collision(true)
