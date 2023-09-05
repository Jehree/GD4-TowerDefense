extends Node2D

func TrackEnemy(enemy:PathFollow2D) -> void:
	look_at(enemy.global_position)
