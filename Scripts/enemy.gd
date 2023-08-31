extends PathFollow2D

@export var moveSpeed := 100.0
@export var maxHealth := 5
var currentHealth: int
@export var enemyDamage := 2
@export var scoreValue := 2

signal ENEMY_DEATH(scoreValue: int)

#THIS FUNC IS ONLY HERE FOR DEBUGGING
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		TakeDamage(1)

func _ready() -> void:
	currentHealth = maxHealth
	%Health_Amount.text = "Health: " + str(currentHealth)

func _physics_process(delta: float) -> void:
	progress += moveSpeed * delta

func TakeDamage(damage: int) -> void:
	currentHealth -= damage
	%Health_Amount.text = "Health: " + str(currentHealth)
	if currentHealth <= 0:
		ENEMY_DEATH.emit(scoreValue)
		queue_free()
		
func DealDamage(damage:int) -> void:
	#TODO - Call func on home base to do damage to it upon collision
	queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("HomeBase"):
		area.get_parent().TakeDamage(enemyDamage)
		queue_free()
		
