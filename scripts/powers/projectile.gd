extends Area2D
class_name Projectile

export(int) var move_speed = 720
export(int) var damage = 70

var direction:int = 1

func _process(delta: float) -> void:
	global_position.x += direction * move_speed * delta

func rotate(sprite_direction: float) -> void:
	if sprite_direction == 1:
		$Texture.flip_h = false
	elif sprite_direction == -1:
		$Texture.flip_h = true
	
func on_screen_exited():
	queue_free()
	
func on_body_entered(body):
	if body is KinematicBody2D:
		body.take_damage(damage)
