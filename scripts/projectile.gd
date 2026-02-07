extends Area2D

var data: Projectile
var velocity: Vector2

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	sprite.region_enabled = false
	sprite.texture = data.sprite
	velocity = transform.x * data.speed
	
func _process(delta: float) -> void:
	position += velocity * delta
