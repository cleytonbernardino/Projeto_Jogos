extends Control

onready var controls: CanvasLayer = $CanvasLayer

func _on_Button_pressed() -> void:
	get_tree().change_scene("res://scenes/menu/fights_select.tscn")


func _on_Controls_pressed():
	controls.init_on_control()
