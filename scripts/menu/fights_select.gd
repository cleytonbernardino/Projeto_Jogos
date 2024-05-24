extends Control

onready var person_select: ItemList = $ItemList

var playerOneSelected: bool = false
var playerTwoSelected: bool = false
var playerOneColor: Color = Color(255, 0, 0)
var playerTwoColor: Color = Color(0, 0, 255)


var person_dir: Array = [
	"res://scenes/fights/Aren.tscn",
	"res://scenes/fights/Baejitul.tscn",
	"res://scenes/fights/CapAfrica.tscn",
	"res://scenes/fights/CTonaldo.tscn",
	"res://scenes/fights/RyanMan.tscn",
]

# Carrega o cenario
func go_to_level() -> void:
	if playerOneSelected and playerTwoSelected:
		get_tree().change_scene("res://scenes/arena/cenarios.tscn")

func _on_ItemList_item_selected(index: int) -> void:
	if not playerOneSelected:
		playerOneSelected = true
		person_select.set_item_custom_bg_color(index, playerOneColor)
		Global.playerOneDir = person_dir[index]
	else:
		playerTwoSelected = true
		person_select.set_item_custom_bg_color(index, playerOneColor)
		Global.playerOneDir = person_dir[index]
	go_to_level()
