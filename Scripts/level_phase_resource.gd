extends Resource
class_name Level_Phase_Resource

@export_category("Enemy Counts")
@export var enemy01_count: int 
@export var enemy02_count: int
@export var enemy03_count: int

@export_category("Enemy Resource Files")
@export var enemy01_res: Enemy_Resource
@export var enemy02_res: Enemy_Resource
@export var enemy03_res: Enemy_Resource

@export_category("Timing")
@export var timeBetweenSpawns: float = 1
@export var phaseCooldown:float = 3


func GetPhaseDictionary() -> Dictionary:
	return {
			ENM.EnemyType.ENEMY01: {
				ENM.DataType.COUNT: enemy01_count,
				ENM.DataType.RESOURCE: enemy01_res
			},
			ENM.EnemyType.ENEMY02: {
				ENM.DataType.COUNT: enemy02_count,
				ENM.DataType.RESOURCE: enemy02_res
			},
			ENM.EnemyType.ENEMY03: {
				ENM.DataType.COUNT: enemy03_count,
				ENM.DataType.RESOURCE: enemy03_res
			}
		}


