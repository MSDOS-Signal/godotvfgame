extends CharacterBody2D



@export var move_speed : float = 100
@export var animator : AnimatedSprite2D
var is_game_over :bool = false
@export var bullet_scene: PackedScene

# 按钮控制变量
var button_input = Vector2.ZERO

# 初始位置
var initial_position = Vector2(-268, 114)

# 音效控制
var sounds_enabled : bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")

func _ready():
	# 保存初始位置
	initial_position = position
	# 初始时禁用音效
	sounds_enabled = false

func _process(delta: float) -> void:
	if velocity==Vector2.ZERO or is_game_over or not sounds_enabled:
		$Run.stop()
	elif not $Run.playing and sounds_enabled:
		$Run.play()

func _physics_process(delta: float) -> void:
	if not is_game_over:
		# 获取键盘输入
		var keyboard_input = Input.get_vector("left","right","up","down")
		# 结合键盘和按钮输入
		var total_input = keyboard_input + button_input
		# 限制输入向量长度为1
		if total_input.length() > 1:
			total_input = total_input.normalized()
		
		velocity = total_input * move_speed
		
		if velocity==Vector2.ZERO:
			animator.play("Idle")
		else:
			animator.play("run")
		move_and_slide()

func game_over():
	if not is_game_over:
		is_game_over=true
		animator.play("GameOver")
		get_tree().current_scene.show_game_over()
		# 只在音效启用时播放GameOver音效
		if sounds_enabled:
			$GameOver.play()
		$Timer2.start()

# 重置玩家状态
func reset_player():
	is_game_over = false
	position = initial_position
	velocity = Vector2.ZERO
	button_input = Vector2.ZERO
	animator.play("Idle")
	$Run.stop()

# 启用音效
func enable_sounds():
	sounds_enabled = true

# 禁用音效
func disable_sounds():
	sounds_enabled = false
	$Run.stop()

func _on_timer_timeout() -> void:
	if velocity !=Vector2.ZERO or is_game_over or not sounds_enabled:
		return
		
	$AudioStreamPlayer.play()
	
	var bullet_node = bullet_scene.instantiate()
	bullet_node.position = position+Vector2(50,18)
	get_tree().current_scene.add_child(bullet_node)


func reload_scene() -> void:
	get_tree().reload_current_scene()

# 按钮控制函数
func _on_button_up_pressed():
	button_input.y = -1

func _on_button_up_released():
	button_input.y = 0

func _on_button_down_pressed():
	button_input.y = 1

func _on_button_down_released():
	button_input.y = 0

func _on_button_left_pressed():
	button_input.x = -1

func _on_button_left_released():
	button_input.x = 0

func _on_button_right_pressed():
	button_input.x = 1

func _on_button_right_released():
	button_input.x = 0
