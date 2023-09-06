extends Node2D
class_name Enemy_Spawner

signal END_OF_PHASE
@onready var spawnCooldownTimer:Timer = %Spawn_Cooldown
var enemyToInstantiate = preload("res://Prefabs/Enemy.tscn")
var enemyOrder:Array[Enemy_Resource] = []

func ReceiveEnemyOrder(newOrder:Array[Enemy_Resource], timeBetweenSpawns:float) -> void:
	enemyOrder = newOrder
	SetSpawnCooldownTimerWaitTime(timeBetweenSpawns)
	StartSpawnCooldownTimer()

func StartSpawnCooldownTimer() -> void:
	spawnCooldownTimer.start()

func SetSpawnCooldownTimerWaitTime(timeBetweenSpawns:float):
	spawnCooldownTimer.wait_time = timeBetweenSpawns

func _on_spawn_cooldown_timeout() -> void:
	if enemyOrder.size() > 0:
		var randomEnemyOrderIndex = randi_range(0, enemyOrder.size()-1)
		InstantiateEnemy(enemyOrder[randomEnemyOrderIndex])
		enemyOrder.remove_at(randomEnemyOrderIndex)
	
	# we check here again because enemyOrder.size() will
	# have changed from the remove_at() call above
	if enemyOrder.size() > 0:
		StartSpawnCooldownTimer()
	
	# we check here again because enemyOrder.size() will
	# have changed from the remove_at() call above
	if enemyOrder.size() <= 0:
		END_OF_PHASE.emit()


func InstantiateEnemy(enemyResource:Enemy_Resource):
	var instance = enemyToInstantiate.instantiate()
	instance.enemyType = enemyResource.enemyType
	instance.enemyDamage = enemyResource.enemyDamage
	instance.moveSpeed = enemyResource.moveSpeed
	instance.maxHealth = enemyResource.maxHealth
	instance.scoreValue = enemyResource.scoreValue
	%Enemy_Path.add_child(instance)



