extends Node2D

@export var maxHealth := 10
var currentHealth: int
signal HOME_HEALTH_UPDATED(newHealthAmount: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currentHealth = maxHealth
	HOME_HEALTH_UPDATED.emit(currentHealth)
	
func TakeDamage(damage: int) -> void:
	currentHealth -= damage
	HOME_HEALTH_UPDATED.emit(currentHealth)


