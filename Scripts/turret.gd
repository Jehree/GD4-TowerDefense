extends Node2D

@export var targetSwapDelay:float
@export var rotationSpeed := 2.0
@export_range(0, 1) var priorityOverrideHealthThreshold:float
@export var enemyPriorityList: Array[ENM.EnemyType]

@onready var gunBarrel := $Gun_Barrel
@onready var targetTracker := $Target_Tracker
@onready var stateChart:StateChart = $Turret_StateChart

var detectedEnemiesDict: Dictionary = {}
var targetedEnemyTrackerKey := ""


func GetHighestPriorityEnemyKey() -> String:
	for enemyType in enemyPriorityList:
		for key in detectedEnemiesDict:
			if enemyType == detectedEnemiesDict[key].enemyType:
				return key
	return targetedEnemyTrackerKey


func StartTargetSwapTimer() -> void:
	$Target_Swap_Timer.wait_time = targetSwapDelay
	$Target_Swap_Timer.start()


# v----- SIGNAL FUNCS -----v
func _on_detection_area_area_entered(area: Area2D) -> void:
	var enemyNode = area.get_parent()
	if enemyNode.is_in_group("Enemy"):
		detectedEnemiesDict[enemyNode.name] = enemyNode
		ToTargetingState()

func _on_detection_area_area_exited(area: Area2D) -> void:
	var enemyNode = area.get_parent()
	if enemyNode.is_in_group("Enemy"):
		detectedEnemiesDict.erase(enemyNode.name)
		
		if detectedEnemiesDict.size() == 0:
			ToIdleState()

func _on_target_swap_timer_timeout() -> void:
	targetedEnemyTrackerKey = GetHighestPriorityEnemyKey()
	print("target swap timeout!!")
# ^----- SIGNAL FUNCS -----^

# v----- STATE CHART FUNCS -----v
func _on_targeting_state_processing(delta) -> void:
	targetTracker.look_at(detectedEnemiesDict[targetedEnemyTrackerKey].global_position)
	
	if targetTracker.rotation > gunBarrel.rotation:
		gunBarrel.rotate(delta * rotationSpeed)
	elif targetTracker.rotation < gunBarrel.rotation:
		gunBarrel.rotate(delta * -rotationSpeed)


func _on_targeting_state_entered() -> void:
	targetedEnemyTrackerKey = GetHighestPriorityEnemyKey()
	print("target swap timer started")
	StartTargetSwapTimer()

func _on_targeting_state_exited() -> void:
	targetedEnemyTrackerKey = ""
	$Target_Swap_Timer.stop()
# ^----- STATE CHART FUNCS -----^

func ToTargetingState() -> void:
	stateChart.send_event("targeting")

func ToIdleState() -> void:
	stateChart.send_event("idle")





