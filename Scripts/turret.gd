extends Node2D

@export var targetSwapDelay:float
@export_range(0, 1) var priorityOverrideHealthThreshold:float
@export var enemyPriorityList: Array[ENM.EnemyType]


@onready var gun := $Gun
@onready var stateChart:StateChart = $Turret_StateChart
var detectedEnemiesDict: Dictionary = {}
var targetedEnemyKey := ""

func GetNewestEnemyKey() -> String:
	var iterCounter:int = 0
	for key in detectedEnemiesDict:
		iterCounter += 1
		if iterCounter == detectedEnemiesDict.size():
			return key
	return targetedEnemyKey


func GetOldestEnemyKey() -> String:
	for key in detectedEnemiesDict:return key
	return targetedEnemyKey


func GetHighestPriorityEnemyKey() -> String:
	for enemyType in enemyPriorityList:
		for key in detectedEnemiesDict:
			if enemyType == detectedEnemiesDict[key].enemyType:
				return key
	return targetedEnemyKey


func StartTargetSwapTimer() -> void:
	$Target_Swap_Timer.wait_time = targetSwapDelay
	$Target_Swap_Timer.start()


# v----- SIGNAL FUNCS -----v
func _on_detection_area_area_entered(area: Area2D) -> void:
	var enemyNode = area.get_parent()
	if enemyNode.is_in_group("Enemy"):
		detectedEnemiesDict[enemyNode.name] = enemyNode
		targetedEnemyKey = GetOldestEnemyKey()
		ToTargetingState()
		print("target swap timer started")
		StartTargetSwapTimer()


func _on_detection_area_area_exited(area: Area2D) -> void:
	var enemyNode = area.get_parent()
	if enemyNode.is_in_group("Enemy"):
		detectedEnemiesDict.erase(enemyNode.name)
		
		if detectedEnemiesDict.size() == 0:
			ToIdleState()
		else:
			targetedEnemyKey = GetOldestEnemyKey()

func _on_target_swap_timer_timeout() -> void:
	targetedEnemyKey = GetHighestPriorityEnemyKey()
# ^----- SIGNAL FUNCS -----^

# v----- STATE CHART FUNCS -----v
func _on_targeting_state_processing(delta) -> void:
	gun.look_at(detectedEnemiesDict[targetedEnemyKey].global_position)

func _on_targeting_state_entered() -> void:
	targetedEnemyKey = GetHighestPriorityEnemyKey()

func _on_targeting_state_exited() -> void:
	targetedEnemyKey = ""
	$Target_Swap_Timer.stop()
# ^----- STATE CHART FUNCS -----^

func ToTargetingState() -> void:
	stateChart.send_event("targeting")

func ToIdleState() -> void:
	stateChart.send_event("idle")


