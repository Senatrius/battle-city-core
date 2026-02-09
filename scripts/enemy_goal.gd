extends Area2D

func hit() -> void:
	EventHandler.base_destroyed.emit()
	queue_free()
