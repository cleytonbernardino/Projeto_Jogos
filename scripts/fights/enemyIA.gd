extends KinematicBody2D

onready var sprite: Sprite = $Texture
onready var animation: AnimationPlayer = $Animation
onready var point: Position2D = $Point
onready var damage_collision: CollisionShape2D = $AttackBox.get_child(0)
onready var SearchArea: Area2D = $SearchArea
onready var attack_timer: Timer = $AttackDelay

export(int) var health = 100
export(int) var mana = 0

export(float) var gravity = 1.0
export(float) var attack_delay = 10000000 # 1.3
export(int) var move_speed = 20

var player_ref
var can_attack:bool = true

var direction: int = 1
var velocity: Vector2 = Vector2.ZERO

var special = ''
var lock_animation: bool = false

var death: bool = false
var block: bool = false
var healtBar 

enum {MOVE, JUMP, ROLL, STOP}
var state = MOVE

func _process(delta: float) -> void:
	apply_gravity(delta)
	match state: 
		MOVE:
			move(delta)
		JUMP:
			#jump(delta)
			state = MOVE
		ROLL:
			special = 'roll'
			#change_collision()
			state = MOVE
		STOP:
			pass # Isso é apenas para travar o movimento do personagem
	velocity = move_and_slide(velocity, Vector2.UP)
	set_animation()

func apply_gravity(delta: float) -> void:
	velocity.y += (gravity * 1000) * delta

func move(delta: float, run: bool = false) -> void:
	# direction = Input.get_axis(keys.esquerda, keys.direita)
	# var backdash_direction: String = keys['esquerda'] if enemy_pos() == 1 else keys['direita']
	var speed = move_speed * 1000
	direction *= -1
	
	"""if block and Input.is_action_just_pressed(backdash_direction):
		special = 'backdash'
		moviment_animation(200, 0.3, 0.0, true)"""
	velocity.x = direction * speed * delta

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

func set_animation() -> void:
	var anim_name: String = 'idle' if !block else 'block'

	"""if special == "in_floor" and velocity.y == 0:
		special = ""
		state = MOVE
		moviment = true"""

	if special != '' and can_attack:
		anim_name = special
	elif velocity.y != 0 and 'damage' in special:
		anim_name = 'jump'
	elif velocity.x != 0:
		anim_name = 'walk'
		"""if is_run:
			anim_name = 'run'"""
	
	animation.play(anim_name)

func basic_attack(damage: float = 0.0) -> void:
	if not player_ref:
		return
	if not damage:
		damage = Global.attack_damage.get(special, 0)
	player_ref.take_damage(damage)
	can_attack = false
	attack_timer.start(attack_delay)
	$HitCount.start()
	mana += Global.special_cust.get(special, 0)
	healtBar.set_mana(mana)

func take_damage(damage: float) -> void:
	health -= damage
	healtBar.damage(damage)
	
	if health <= 0:
		death = true

func choice_attack() -> String:
	if mana < 30:
		return 'punch'
	else:
		return 'special2'

func _on_SearchArea_body_shape_entered(
	_body_rid, body, _body_shape_index, _local_shape_index
) -> void:
	if body == self:
		return
	special = choice_attack()
	lock_animation = true

func _on_SearchArea_body_shape_exited(
	_body_rid, _body, _body_shape_index, _local_shape_index
) -> void:
	special = ""
	lock_animation = false

func _on_AttackBox_area_entered(area):
	var parent = area.get_parent()
	if parent.get_groups() == get_groups():
		return

	player_ref = parent
	if special == 'jumpPunch':
		basic_attack(30)
		_on_Animation_animation_finished(special)
	elif special == "runKick":
		basic_attack(20)
		#impact()
		_on_Animation_animation_finished(special)

func _on_AttackDelay_timeout():
	can_attack = true

func _on_AttackBox_area_exited(_area):
	player_ref = null
	state = MOVE

func _on_Animation_animation_finished(_anim_name: String):
	if lock_animation:
		return
	special = ""
