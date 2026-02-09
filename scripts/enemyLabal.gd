extends Label

var enemy_count: int = 0

func _ready() -> void:
	enemy_count = get_tree().get_nodes_in_group("enemy").size()
	EventHandler.enemy_died.connect(update)
	update()

func update() -> void:
	text = "Enemies Left: " + str(enemy_count)
	enemy_count -= 1;
