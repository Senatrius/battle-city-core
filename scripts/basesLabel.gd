extends Label

func _ready() -> void:
	update()
	EventHandler.base_destroyed.connect(update)

func update() -> void:
	call_deferred("count_bases")

func count_bases() -> void:
	var base_count = get_tree().get_nodes_in_group("enemy_bases").size()
	text = "Enemy bases left: " + str(base_count)
