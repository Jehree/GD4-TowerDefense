extends Node2D
class_name TurretBarrelEnd

@onready var turretNode:Turret = get_parent().get_parent()
@onready var levelNode:Node2D = turretNode.get_parent()
@onready var fireCooldownTimer:Timer = $Fire_Cooldown

@export var timeBetweenShots:float = 1
@export var bulletVelocity:float = 100

var bulletToInstantiate := preload("res://Prefabs/bullet.tscn")


func _on_targeting_state_entered() -> void:
	fireCooldownTimer.wait_time = timeBetweenShots
	fireCooldownTimer.start()

func _on_targeting_state_exited() -> void:
	fireCooldownTimer.stop()

func InstantiateBullet() -> void:
	var bulletInstance:RigidBody2D = bulletToInstantiate.instantiate()
	var bulletRotation := self.global_rotation
	bulletInstance.rotation = bulletRotation
	bulletInstance.position = self.global_position
	levelNode.add_child(bulletInstance)
	var bulletDirection := self.global_transform.x
	bulletInstance.apply_central_impulse(bulletDirection * bulletVelocity)


func _on_fire_cooldown_timeout() -> void:
	InstantiateBullet()
