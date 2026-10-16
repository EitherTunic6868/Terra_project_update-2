extends Node

var score = 0
@onready var score_label: Label = $"../Score label"

signal damage_player
signal kill_player


func add_point():
	score += 1
	score_label.text = str(score) + " coins"



func _on_slime_damage_to_player(damage) -> void:
	emit_signal("damage_player", damage)


func _on_killzone_killzone_die() -> void:
	emit_signal("kill_player")
