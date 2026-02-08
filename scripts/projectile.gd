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


func _on_body_entered(body: Node2D) -> void:
	print(body)
	if body is TileMapLayer:
		var direction = transform.x
		var impact_pos = global_position + (direction * 2.0)
		var local_pos = body.to_local(impact_pos)
		var map_pos = body.local_to_map(local_pos)
		
		var tile_data = body.get_cell_tile_data(map_pos)
		print(tile_data)
		if tile_data:
			var can_destroy = tile_data.get_custom_data("breakable")
			
			if can_destroy:
				body.erase_cell(map_pos)
		
		queue_free()
