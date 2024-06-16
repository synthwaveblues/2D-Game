extends ProgressBar

@onready var timer = $Timer
@onready var damage_bar = $DamageBar
@onready var player = $"../.."

# Called when the node enters the scene tree for the first time.
func _ready():
	update()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func update():
	value = player.health * 10 / player.maxHealth
