extends CharacterBody2D
@export var tank_data: Tank
@export var projectile_scene: PackedScene

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var projectileOrigin: Marker2D = $BulletSpawner

var cooldown_timer: float = 0.0

func _ready() -> void:
	sprite.sprite_frames = tank_data.animatedSprite
	sprite.play("default")

func _physics_process(delta) -> void:
	cooldown_timer -= delta
	
	var direction = Input.get_vector("left", "right", "up", "down")
	
	if Input.is_action_pressed('right'):
		direction = Vector2.RIGHT
	elif Input.is_action_pressed('left'):
		direction = Vector2.LEFT
	elif Input.is_action_pressed('down'):
		direction = Vector2.DOWN
	elif Input.is_action_pressed('up'):
		direction = Vector2.UP
	
	if direction != Vector2.ZERO:
		rotation = direction.angle()
	
	velocity = (direction * tank_data.speed)
	
	if Input.is_action_just_pressed("shoot") and cooldown_timer <= 0.0:
		shoot();
		cooldown_timer = tank_data.firerate
	
	move_and_slide()
	
func shoot() -> void:
	var bullet = projectile_scene.instantiate()
	bullet.data = tank_data.projectileData
	bullet.position = projectileOrigin.global_position;
	bullet.rotation = rotation
	bullet.setup(true)
	get_parent().add_child(bullet)

func hit() -> void:
	EventHandler.player_hit.emit()
