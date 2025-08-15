extends Area2D

@export var bullet_speed:float = 650

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("bullet")
	await get_tree().create_timer(3)	.timeout
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position+=Vector2(bullet_speed,0)* delta
