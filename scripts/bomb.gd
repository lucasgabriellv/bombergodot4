extends Area2D

signal exploded

func _ready():
	$LightUpTimer.start()
	$AnimatedSprite2D.animation = "idle"
	$AnimatedSprite2D.play()

func _process(delta):
	pass

func _on_light_up_timer_timeout():
	$FuseTimer.start()
	$AnimatedSprite2D.animation = "burning"
	$AnimatedSprite2D.play()

func _on_fuse_timer_timeout():
	hide()
	queue_free()
	exploded.emit()
