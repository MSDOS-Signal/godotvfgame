extends Node2D

@export var slime_scene:PackedScene
@export var spawn_timer :Timer
@export var score :int =0
@export var score_label:Label
@export var game_over_label:Label

# 摄像机引用
@onready var camera2d = $Camera2D
@onready var camera2d2 = $Camera2D2

# 最高分数
var high_score : int = 0

# 游戏状态
enum GameState {MENU, PLAYING, GAME_OVER}
var current_state = GameState.MENU

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 确保摄像机初始状态正确
	if camera2d:
		camera2d.enabled = false
	if camera2d2:
		camera2d2.enabled = true
	
	# 启动时显示主菜单
	show_main_menu()
	
	# 加载最高分数
	load_high_score()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# 只在游戏进行中时更新游戏逻辑
	if current_state == GameState.PLAYING:
		spawn_timer.wait_time-=0.2*delta
		spawn_timer.wait_time=clamp(spawn_timer.wait_time,1,3)
		score_label.text="分数:"+ str(score)

func spawnSlime() -> void:
	if current_state == GameState.PLAYING:
		var slime_node = slime_scene.instantiate()
		slime_node.position =Vector2(-362,randf_range(-485,-354  ))
		get_tree().current_scene.add_child(slime_node)

func _on_timer_timeout() -> void:
	pass # Replace with function body.

func show_game_over():
	if current_state == GameState.PLAYING:
		current_state = GameState.GAME_OVER
		game_over_label.visible=true
		
		# 更新最高分数
		update_high_score()

# 显示主菜单
func show_main_menu():
	current_state = GameState.MENU
	camera2d.enabled = false
	camera2d2.enabled = true
	
	# 停止游戏逻辑
	spawn_timer.stop()
	# 重置分数为0
	score = 0
	score_label.text = "分数:0"
	game_over_label.visible = false
	
	# 控制UI元素显示/隐藏
	control_ui_visibility(true)
	
	# 重置玩家位置和状态
	if has_node("Player"):
		var player = $Player
		player.reset_player()
		# 禁用玩家音效
		disable_player_sounds(player)
	
	# 清除所有史莱姆
	for child in get_children():
		if child.name.begins_with("Area2D") and child != $Area2D:
			child.queue_free()
	
	# 播放背景音乐
	if has_node("Bgm"):
		var bgm = $Bgm
		if bgm is AudioStreamPlayer:
			bgm.play()

# 开始游戏
func start_game():
	current_state = GameState.PLAYING
	camera2d.enabled = true
	camera2d2.enabled = false
	
	# 重置分数为0
	score = 0
	score_label.text = "分数:0"
	game_over_label.visible = false
	
	# 控制UI元素显示/隐藏
	control_ui_visibility(false)
	
	# 开始游戏逻辑
	spawn_timer.start()
	
	# 启用玩家音效
	if has_node("Player"):
		var player = $Player
		enable_player_sounds(player)
	
	# 停止背景音乐
	if has_node("Bgm"):
		var bgm = $Bgm
		if bgm is AudioStreamPlayer:
			bgm.stop()

# 重新开始游戏（重置分数）
func restart_game():
	# 重置分数
	score = 0
	score_label.text = "分数:0"
	start_game()

# 退出游戏
func exit_game():
	# 退出前更新最高分数
	update_high_score()
	get_tree().quit()

# 保存最高分数
func save_high_score():
	var save_file = FileAccess.open("user://high_score.save", FileAccess.WRITE)
	if save_file:
		save_file.store_var(high_score)
		save_file.close()

# 加载最高分数
func load_high_score():
	if FileAccess.file_exists("user://high_score.save"):
		var save_file = FileAccess.open("user://high_score.save", FileAccess.READ)
		if save_file:
			high_score = save_file.get_var()
			save_file.close()
			update_high_score_label()

# 更新最高分数
func update_high_score():
	if score > high_score:
		high_score = score
		save_high_score()
		update_high_score_label()

# 更新最高分数显示
func update_high_score_label():
	if has_node("CanvasLayer/Label4"):
		var high_score_label = $CanvasLayer/Label4
		high_score_label.text = "最高分数: " + str(high_score)

# 控制UI元素显示/隐藏
func control_ui_visibility(is_menu: bool):
	var canvas_layer = $CanvasLayer
	if canvas_layer:
		# 主菜单时显示Label3和Label4，隐藏GameOver3和GameOver4
		if has_node("CanvasLayer/GameOver3"):
			canvas_layer.get_node("GameOver3").visible = not is_menu
		if has_node("CanvasLayer/GameOver4"):
			canvas_layer.get_node("GameOver4").visible = not is_menu
		if has_node("CanvasLayer/Label3"):
			canvas_layer.get_node("Label3").visible = is_menu
		if has_node("CanvasLayer/Label4"):
			canvas_layer.get_node("Label4").visible = is_menu
		# 控制分数标签显示
		if has_node("CanvasLayer/Label"):
			canvas_layer.get_node("Label").visible = not is_menu
		# 控制游戏标题标签显示
		if has_node("CanvasLayer/Label2"):
			canvas_layer.get_node("Label2").visible = is_menu

# 禁用玩家音效
func disable_player_sounds(player):
	player.disable_sounds()

# 启用玩家音效
func enable_player_sounds(player):
	player.enable_sounds()

# 按钮信号处理函数
func _on_start_game_button_pressed():
	start_game()

func _on_exit_button_pressed():
	exit_game()

func _on_exit_to_menu_button_pressed():
	show_main_menu()

func _on_restart_button_pressed():
	restart_game()

func _on_reset_high_score_button_pressed():
	reset_high_score()

# 重置最高分数
func reset_high_score():
	high_score = 0
	save_high_score()
	update_high_score_label()
	
