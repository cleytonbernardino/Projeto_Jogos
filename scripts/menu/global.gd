extends Node

var playerOneDir: String
var playerTwoDir: String
var wins: Array = [0, 0] # 0 - Player One | 1 - Player Two

var attack_damage: Dictionary = {
	"punch": 20,
	"runKick": 20,
	"special2": 40,
	"special3": 20,
	"special4": 20, # TEMPORARIO
	"super": 50
}

var special_cust: Dictionary = {
	"jumpKick": 15,
	"jumpPunch": 15,
	"kick": 10,
	"punch": 10,
	"special1": -20,
	"special2": -30,
	"special3": -50,
	"special4": -60,
	"super": -100,
}

var fights: Array =  [
	"res://scenes/fights/Aren.tscn",
	"res://scenes/fights/Badman.tscn",
	"res://scenes/fights/Baejitul.tscn",
	"res://scenes/fights/CapAfrica.tscn",
	"res://scenes/fights/CTonaldo.tscn",
	"res://scenes/fights/RyanMan.tscn",
	"res://scenes/fights/Sonogong.tscn",
	"res://scenes/fights/Sutoman.tscn",
]

func instance_node(node, location, parent):
	var node_instace = node.instance()
	parent.add_child(node_instace)
	node_instace.global_position = location
	return node_instace
