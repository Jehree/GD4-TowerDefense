extends Label

func _on_home_base_home_health_updated(newHealthAmount) -> void:
	self.text = "Player Health: " + str(newHealthAmount)
