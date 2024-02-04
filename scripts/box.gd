extends RigidBody2D

signal box_destroyed

@export var coords: Vector2

func _ready():
	$AnimatedSprite2D.play('default')

func _process(delta):
	pass

func hit():
	$AnimatedSprite2D.play('burning')
	$BurnTimer.start()


func _on_burn_timer_timeout():
	box_destroyed.emit(coords)
	queue_free()
