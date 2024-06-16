extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	ghosting() # Replace with function body.
	
func set_property(tx_pos,tx_scale, flip_h2):
	position = tx_pos
	scale = tx_scale
	flip_h = flip_h2
	
func ghosting():
	var tween_fade = get_tree().create_tween()
	
	tween_fade.tween_property(self,"self_modulate",Color(0, 0, 0, 0),0.75)
	await tween_fade.finished
	queue_free()
