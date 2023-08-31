extends Node
class_name Level_Controller

@export var phases: Array[Level_Phase_Resource]
@onready var remainingPhases:int = phases.size()
var sentPhases := 0
var endOfPhase := false
@onready var enemySpawner:Enemy_Spawner = %Enemy_Spawner
@onready var levelStateChart:StateChart = %Level_StateChart


func HandlePhases() -> void:
	if remainingPhases >= 0:
		remainingPhases -= 1
		StartPhaseCooldownTimer()


func StartPhaseCooldownTimer() -> void:
	if remainingPhases >= 0:
		var phaseCooldownTime = GetPhaseCooldown()
		%Phase_Cooldown.wait_time = phaseCooldownTime
		print("Phase cooldown timer started... " + str(phaseCooldownTime) + " seconds")
		%Phase_Cooldown.start()


func SendEnemyOrder() -> void:
	enemySpawner.ReceiveEnemyOrder(BuildEnemySpawnOrder(), GetTimeBetweenSpawns())
	sentPhases += 1


func BuildEnemySpawnOrder() -> Array[Enemy_Resource]:
	#this array will be sent to the enemy spawner script to handle
	var phase: Level_Phase_Resource = phases[sentPhases]
	var enemyResourcesOrder: Array[Enemy_Resource] = []
	var phaseDict:Dictionary = phase.GetPhaseDictionary()

	for dictIndex in phaseDict:
		var thisEnemyElement = phaseDict[dictIndex]
		var thisEnemyCount = thisEnemyElement[ENM.DataType.COUNT]
		var thisEnemyResource = thisEnemyElement[ENM.DataType.RESOURCE]
		
		for i in thisEnemyCount:
			enemyResourcesOrder.append(thisEnemyResource)
			
	return enemyResourcesOrder


func AllPhasesAndSpawnsComplete() -> bool:
	var allPhasesSent:bool
	
	if remainingPhases <= 0:
		allPhasesSent = true
	else:
		allPhasesSent = false
	
	if allPhasesSent and endOfPhase:
		return true
	else:
		return false


#v----- SIGNAL FUNCS -----v
func _on_home_base_home_health_updated(newHealthAmount) -> void:
	if newHealthAmount <= 0:
		TolossState()

func _on_enemy_spawner_end_of_phase() -> void:
	print("endOfPhase set to true")
	endOfPhase = true

func _on_phase_cooldown_timeout() -> void:
	print("Phase Cooldown Timeout!")
	ToPhaseActiveState()

func _on_enemy_path_child_exiting_tree(node: Node) -> void:
	var remainingEnemyCount = node.get_parent().get_child_count() - 1
	
	if remainingEnemyCount > 0:
		return
	if AllPhasesAndSpawnsComplete():
		ToWinState()
	elif endOfPhase:
		ToPhaseInitState()
		print("endOfPhase set to false")
		endOfPhase = false
#^----- SIGNAL FUNCS -----^

#v----- STATE CHART FUNCS -----v
func _on_win_state_entered() -> void:
	print("You beat this level!")

func _on_loss_state_entered() -> void:
	print("Game Over!")

func _on_phase_initializing_state_entered() -> void:
	HandlePhases()

func _on_phase_active_state_entered() -> void:
	SendEnemyOrder()
#^----- STATE CHART FUNCS -----^


func ToWinState() -> void:
	levelStateChart.send_event("win")

func TolossState() -> void:
	levelStateChart.send_event("loss")

func ToPhaseActiveState() -> void:
	levelStateChart.send_event("phase_active")

func ToPhaseInitState() -> void:
	levelStateChart.send_event("phase_init")

func GetTimeBetweenSpawns() -> float:
	return phases[sentPhases].timeBetweenSpawns

func GetPhaseCooldown() -> float:
	return phases[sentPhases].phaseCooldown
