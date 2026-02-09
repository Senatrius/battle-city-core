extends CharacterBody2D

@export var tank_data: Tank
@export var projectile_scene: PackedScene
@export var player: Node2D
@export var base: Area2D
@export var shot_chance_player: float = 0.5
@export var death_animation: PackedScene

@export var goal_interest: float = 0.6
@export var defense_radius: float = 150.0

var current_direction: Vector2 = Vector2.DOWN
var move_timer: float = 0.0
var decision_timer: float = 0.0
var active_goal_pos: Vector2

@onready var ray: RayCast2D = $RayCast2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var projectileOrigin: Marker2D = $BulletSpawner

func _ready() -> void:
	sprite.sprite_frames = tank_data.animatedSprite
	sprite.play("default")
	_choose_new_direction()

func _physics_process(delta: float) -> void:
	move_timer -= delta
	decision_timer -= delta
	
	if decision_timer <= 0:
		_make_combat_decision()
		decision_timer = randf_range(0.5, 1.5)
	
	if move_timer <= 0 or is_on_wall():
		_choose_new_direction()
		move_timer = randf_range(1.0, 3.0) 
	
	velocity = current_direction * tank_data.speed
	move_and_slide()

func _choose_new_direction() -> void:
	global_position = global_position.snapped(Vector2(4, 4))
	_update_active_goal()
	
	var directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
	var opposite = -current_direction
	var is_focused = randf() < goal_interest
	
	if is_focused:
		directions.sort_custom(func(a, b):
			var dist_a = (global_position + a * 16).distance_to(active_goal_pos)
			var dist_b = (global_position + b * 16).distance_to(active_goal_pos)
			return dist_a < dist_b
		)
	else:
		directions.shuffle()

	var best_dir = Vector2.ZERO
	for dir in directions:
		if dir == opposite and directions.size() > 1: continue
		if not test_move(transform, dir * 4.0):
			best_dir = dir
			break
	
	if best_dir == Vector2.ZERO: best_dir = opposite
	
	current_direction = best_dir
	rotation = current_direction.angle()
	ray.target_position = Vector2(150, 0)

func _update_active_goal() -> void:
	active_goal_pos = player.global_position if player else base.global_position
	var bases = get_tree().get_nodes_in_group("enemy_bases")
	for b in bases:
		if player and b.global_position.distance_to(player.global_position) < defense_radius:
			active_goal_pos = (player.global_position + b.global_position) / 2
			break

func _make_combat_decision() -> void:
	if not ray.is_colliding(): return
	
	var target = ray.get_collider()
	
	print(target)
	if target.is_in_group("player"):
		if randf() < shot_chance_player:
			fire()
	
	elif target is TileMapLayer:
		var dist = global_position.distance_to(ray.get_collision_point())
		if dist < 20.0 and randf() < 0.2:
			fire()

func fire() -> void:
	if not projectile_scene: return
	var bullet = projectile_scene.instantiate()
	bullet.data = tank_data.projectileData
	
	if bullet.has_method("setup"):
		bullet.setup(false) 
	
	bullet.global_position = projectileOrigin.global_position
	bullet.rotation = rotation
	get_parent().add_child(bullet)

func die() -> void:
	var explosion = death_animation.instantiate()
	explosion.global_position = global_position
	get_parent().add_child(explosion)
	
	queue_free()
