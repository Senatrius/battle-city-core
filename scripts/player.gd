extends CharacterBody2D
@export var tank_data: Tank

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var projectileOrigin: Marker2D = $Marker2D

func _ready() -> void:
	sprite.sprite_frames = tank_data.animatedSprite
	sprite.play("idle")

func _physics_process(_delta):
# setup direction of movement
	var direction = Input.get_vector("left", "right", "up", "down")
# stop diagonal movement by listening for input then setting axis to zero
	if Input.is_action_pressed("right") || Input.is_action_pressed("left"):
		direction.y = 0
	elif Input.is_action_pressed("up") || Input.is_action_pressed("down"):
		direction.x = 0
	else:
		direction = Vector2.ZERO
	
#normalize the directional movement
	direction = direction.normalized()
# setup the actual movement
	velocity = (direction * tank_data.speed)
	move_and_slide()
