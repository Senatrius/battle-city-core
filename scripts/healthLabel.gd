extends Label

var hits: int = 0;

func _ready() -> void:
	text = "Hits taken: " + str(hits)
	EventHandler.player_hit.connect(update)

func update() -> void:
	hits += 1
	
	text = "Hits taken: " + str(hits)
