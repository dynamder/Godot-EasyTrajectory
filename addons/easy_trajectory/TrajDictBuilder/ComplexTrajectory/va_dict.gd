extends BaseDictBuilder
class_name VaTrajDict

var velocity: Vector2
var acceleration: Vector2 = Vector2.ZERO
var ending_phase: float = -1

func build() -> Dictionary:
	return {
		"velocity": velocity,
		"acceleration": acceleration,
		"ending_phase": ending_phase
	}

func set_vel(set_velocity: Vector2) -> VaTrajDict:
	self.velocity = set_velocity
	return self
	
func set_accel(set_acceleration: Vector2) -> VaTrajDict:
	self.acceleration = set_acceleration
	return self
	
func set_ending_phase(set_ending_phase : float) -> VaTrajDict:
	self.ending_phase = set_ending_phase
	return self
