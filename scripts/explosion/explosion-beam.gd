extends Area2D

signal player_hit
signal box_hit

func _ready():
	pass

func _process(delta):
	pass

func _on_body_entered(body: Node2D):
	if body.name == "Player":
		player_hit.emit()
	if body.is_in_group("destructibles"):
		box_hit.emit()
