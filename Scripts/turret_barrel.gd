extends Node2D
class_name TurretBarrel


func TurnTowardTarget(targetTracker:Node2D, turnSpeed:float) -> void:
	if targetTracker.rotation > self.rotation:
		self.rotate(turnSpeed)
	elif targetTracker.rotation < self.rotation:
		self.rotate(-turnSpeed)

