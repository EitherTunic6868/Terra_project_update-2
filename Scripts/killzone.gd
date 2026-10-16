extends Area2D

signal killzone_die

func _on_body_entered(_body: Node2D) -> void:
	emit_signal("killzone_die")
