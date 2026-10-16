extends Area2D

const ADD_HEALTH = 20
signal heal

var active = false
var active_count = 0

@onready var sprite: Sprite2D = $Sprite2D

func _on_player_immunity_stopped() -> void:
	if active_count == 0:
		active = true
		active_count += 1

func _on_body_entered(_body: Node2D) -> void:
	if active == true:
		emit_signal("heal", ADD_HEALTH)
		sprite.hide()
		active = false
