extends Node

var playerOneDir: String
var playerTwoDir: String
var wins: Array = [0, 0] # 0 - Player One | 1 - Player Two

var attack_damage: Dictionary = {
	"punch": 20,
	"runKick": 35,
	"projectile": 70,
	"kame_damage": 180,
	"special2": 80,
	"special3": 70,
	"super": 200
}

var special_cust: Dictionary = {
	"jumpPunch": 10,
	"runkick": 10,
	"punch": 5,
	"special1": -35,
	"special2": -45,
	"special3": -60,
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
