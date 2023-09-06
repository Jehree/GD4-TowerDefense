extends Node2D

@export var targetSwapDelay:float
@export var rotationSpeed := 2.0
@export var projectileDamage:int = 1
@export var directDamage:int = 0
@export var timeBetweenShots:float = 1
@export var bulletVelocity:float = 1
@export_range(0, 1) var priorityOverrideHealthThreshold:float
@export var enemyPriorityList: Array[ENM.EnemyType]

@onready var turretBarrel:Node2D = $Turret_Barrel
@onready var stateChart:StateChart = $Turret_StateChart
@onready var targetTracker:Node2D = $Target_Tracker
@onready var fireCooldownTimer:Timer = $Fire_Cooldown
@onready var targetSwapTimer:Timer = $Target_Swap_Timer

var detectedEnemiesDict: Dictionary = {}
var targetedEnemyTrackerKey := ""

func _ready() -> void:
	targetSwapTimer.wait_time = targetSwapDelay

func GetHighestPriorityEnemyKey() -> String:
	for enemyType in enemyPriorityList:
		for key in detectedEnemiesDict:
			if enemyType == detectedEnemiesDict[key].enemyType:
				return key
	return targetedEnemyTrackerKey


# v----- SIGNAL FUNCS -----v
func _on_detection_area_area_entered(area: Area2D) -> void:
	var enemyNode:PathFollow2D = area.get_parent()
	
	if !has_signal("ENEMY_DEATH"):
		enemyNode.connect("ENEMY_DEATH", self._on_enemy_death)
	
	if enemyNode.is_in_group("Enemy"):
		detectedEnemiesDict[enemyNode.name] = enemyNode
		ToTargetingState()

func _on_detection_area_area_exited(area: Area2D) -> void:
	var enemyNode:PathFollow2D = area.get_parent()
	if enemyNode.is_in_group("Enemy"):
		detectedEnemiesDict.erase(enemyNode.name)
		
		if detectedEnemiesDict.size() == 0:
			ToIdleState()

func _on_target_swap_timer_timeout() -> void:
	targetedEnemyTrackerKey = GetHighestPriorityEnemyKey()
# ^----- SIGNAL FUNCS -----^

# v----- TARGETING STATE CHART FUNCS -----v
func _on_targeting_state_processing(delta) -> void:
	if detectedEnemiesDict.has(targetedEnemyTrackerKey):
		targetTracker.TrackEnemy(detectedEnemiesDict[targetedEnemyTrackerKey])
	
	turretBarrel.TurnToTargetRotation(targetTracker, rotationSpeed * delta)
	
	if turretBarrel.CheckIfOnTarget(targetTracker, 0.25):
		ToFireShotState()

func _on_targeting_state_entered() -> void:
	targetedEnemyTrackerKey = GetHighestPriorityEnemyKey()
	targetSwapTimer.start()

func _on_enemy_death(_scoreValue, enemyName) -> void:
	detectedEnemiesDict.erase(enemyName)
	targetedEnemyTrackerKey = GetHighestPriorityEnemyKey()
	targetSwapTimer.stop()
	targetSwapTimer.start()

func _on_targeting_state_exited() -> void:
	targetedEnemyTrackerKey = ""
	$Target_Swap_Timer.stop()
# ^----- TARGETING STATE CHART FUNCS -----^

# v-- SHOOTING FUNCS --v
func _on_fire_shot_state_entered() -> void:
	
	if projectileDamage > 0:
		turretBarrel.InstantiateBullet()
	
	if directDamage > 0 and detectedEnemiesDict.has(targetedEnemyTrackerKey):
		var enemy:PathFollow2D = detectedEnemiesDict[targetedEnemyTrackerKey]
		enemy.TakeDamage(directDamage)
	
	ToShotOnCooldownState()

func _on_shot_on_cooldown_state_entered() -> void:
	fireCooldownTimer.wait_time = timeBetweenShots
	fireCooldownTimer.start()

func _on_fire_cooldown_timeout() -> void:
	ToReadyToFireState()
#^-- SHOOTING FUNCS --^


func ToReadyToFireState() -> void:
	stateChart.send_event("ready_to_fire")
func ToFireShotState() -> void:
	stateChart.send_event("fire_shot")
func ToShotOnCooldownState() -> void:
	stateChart.send_event("shot_on_cooldown")
func ToTargetingState() -> void:
	stateChart.send_event("targeting")
func ToIdleState() -> void:
	stateChart.send_event("idle")



