extends Control

@onready var health_bar: ProgressBar = $"Player Health Bar"


func _on_player_update_player_health(health) -> void:
	health_bar.value = health
