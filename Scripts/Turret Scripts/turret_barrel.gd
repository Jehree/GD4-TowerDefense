extends Node2D

var bulletToInstantiate := preload("res://Prefabs/bullet.tscn")

func TurnToTargetRotation(targetTracker:Node2D, turnSpeed:float) -> void:
	if targetTracker.rotation > self.rotation:
		self.rotate(turnSpeed)
	elif targetTracker.rotation < self.rotation:
		self.rotate(-turnSpeed)

func InstantiateBullet(bulletVelocity:float) -> void:
	var bulletInstance:RigidBody2D = bulletToInstantiate.instantiate()
	var bulletRotation := self.global_rotation
	
	bulletInstance.rotation = bulletRotation
	bulletInstance.position = self.global_position
	
	var turretNode:Node2D = owner
	turretNode.owner.add_child(bulletInstance)
	
	var bulletDirection := self.global_transform.x
	bulletInstance.apply_central_impulse(bulletDirection * bulletVelocity)

func CheckIfOnTarget(targetTracker, aimOffset) -> bool:
	var targetRot = targetTracker.rotation
	var selfRot = self.rotation
	
	if targetRot >= selfRot - aimOffset and targetRot <= selfRot + aimOffset:
		return true
	else:
		return false
