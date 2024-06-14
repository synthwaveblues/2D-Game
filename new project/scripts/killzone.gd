extends Area2D

func _on_body_entered(body):
	print ("You died")
	$Timer.start()

func _on_timer_timeout():
	get_tree().reload_current_scene()

