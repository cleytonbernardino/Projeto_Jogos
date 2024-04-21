extends Node

var playerOneDir: String = "res://scenes/fights/ryanMan.tscn"
var playerTwoDir: String = "res://scenes/fights/baejitul.tscn"

func instance_node(node, location, parent):
	var node_instace = node.instance()
	parent.add_child(node_instace)
	node_instace.global_position = location
	return node_instace
