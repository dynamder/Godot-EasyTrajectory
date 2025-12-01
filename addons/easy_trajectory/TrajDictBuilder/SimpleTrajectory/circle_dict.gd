extends BaseDictBuilder
class_name CircleTrajDict

var radius: float
var angular_speed: float
var angle : float = 0
var angular_acceleration: float = 0
var ending_phase: float = -1

func build() -> Dictionary:
	return {
		"radius": radius,
		"angle": angle,
		"angular_speed": angular_speed,
		"angular_acceleration": angular_acceleration,
		"ending_phase": ending_phase
	}

func set_radius(set_radius: float) -> CircleTrajDict:
	self.radius = set_radius
	return self
	
func set_angle(set_angle: float) -> CircleTrajDict:
	self.angle = set_angle
	return self
	
func set_ang_speed_accel(set_ang_speed: float, set_ang_accleration: float = 0) -> CircleTrajDict:
	self.angular_speed = set_ang_speed
	self.angular_acceleration = set_ang_accleration
	return self

func set_ending_phase(set_ending_phase) -> CircleTrajDict:
	self.ending_phase = set_ending_phase
	return self
