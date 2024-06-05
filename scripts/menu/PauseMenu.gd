extends CanvasLayer
class_name Pause_Menu

onready var controls: CanvasLayer = $ControlsLayer

var only_controls = false
var ignore

func _ready():
	visible = false

func _unhandled_input(event):
	if event.is_action_pressed("ui_pause") and controls.visible:
		if only_controls:
			ignore = get_tree().change_scene("res://scenes/menu/MainMenu.tscn")
		controls.visible = false
		change_menu(true)
		return
	
	if event.is_action_pressed("ui_pause") and get_tree().paused:
		_on_Continue_btn_pressed()
	elif event.is_action_pressed("ui_pause"):
		visible = true
		get_tree().paused = true
	
func change_menu(invert: bool = false) -> void:
	$MenuHolder.visible = invert
	$Backgrorund.visible = invert

func init_on_control() -> void:
	visible = true
	controls.visible = true
	only_controls = true
	$ControlsLayer/Return_btn.text = "<> Menu <>"
	change_menu()


func _on_Continue_btn_pressed():
	get_tree().paused = false
	visible = false


func _on_SeeControls_btn_pressed():
	controls.visible = true
	change_menu()


func _on_Restart_btn_pressed():
	ignore = get_tree().reload_current_scene()
	_on_Continue_btn_pressed()


func _on_Quit_btn_pressed():
	get_tree().quit()


func _on_Return_btn_pressed():
	if only_controls:
		visible = false
		controls.visible = false
		return
	controls.visible = false
	change_menu(true)


func _on_Selectd_btn_pressed():
	get_tree().paused = false
	Global.playerOneDir = ""
	Global.playerTwoDir = ""
	ignore = get_tree().change_scene("res://scenes/menu/fights_select.tscn")
