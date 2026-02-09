extends Area2D

@export var hit_animation: PackedScene
@export var radius: int

var data: Projectile
var velocity: Vector2

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	sprite.region_enabled = false
	sprite.texture = data.sprite
	velocity = transform.x * data.speed

func setup(is_player):
	
	if is_player:
		set_collision_layer_value(4, true);
		set_collision_mask_value(3, true)
	else:
		set_collision_layer_value(5, true);
		set_collision_mask_value(2, true)
	
func _process(delta: float) -> void:
	position += velocity * delta


func _on_body_entered(body: Node2D) -> void:
		
	if body is TileMapLayer:
		explode(body)
		var hit = hit_animation.instantiate();
		hit.global_position = global_position
		hit.rotation = rotation
		get_parent().add_child(hit)
		
		var direction = transform.x
		var impact_pos = global_position + (direction * 2.0)
		var local_pos = body.to_local(impact_pos)
		var map_pos = body.local_to_map(local_pos)
		
		var tile_data = body.get_cell_tile_data(map_pos)
		
		if tile_data:
			var can_destroy = tile_data.get_custom_data("breakable")
			
			if can_destroy:
				body.erase_cell(map_pos)
		
		queue_free()
		
func explode(tileset):
	var tile_range = ceil(radius / 2)
	var explosion_epicenter = tileset.local_to_map(tileset.to_local(global_position))
	
	for x in range(-tile_range, tile_range + 1):
		for y in range(-tile_range, tile_range + 1):
			
			var current_tile = explosion_epicenter + Vector2i(x, y)
			
			# Calculate if this specific tile is actually inside the circle radius
			var tile_global_pos = tileset.to_global(tileset.map_to_local(current_tile))
			if global_position.distance_to(tile_global_pos) <= radius:
				
				print("Checking tile at: ", current_tile, " Distance: ", global_position.distance_to(tile_global_pos))
				# 5. Check if it's breakable
				var data = tileset.get_cell_tile_data(current_tile)
				if data and data.get_custom_data("breakable"):
					tileset.erase_cell(current_tile)
