extends BaseDictBuilder
class_name LinearTrajDict

var speed : float
var acceleration: float = 0
var direction: float
var ending_phase: float = -1	

func build() -> Dictionary:
	return {
		"speed" : speed,
		"acceleration" : acceleration,
		"direction" : direction,
		"ending_phase" : ending_phase
	}

##允许链式调用，当所需构建参数较多时会更清晰
func set_speed_accel(set_speed: float, set_accel: float = 0) -> LinearTrajDict:
	self.speed = set_speed
	self.acceleration = set_accel
	return self

func set_direction(set_direction: float) -> LinearTrajDict:
	self.direction = set_direction
	return self
	
func set_ending_phase(set_ending_phase: float) -> LinearTrajDict:
	self.ending_phase = set_ending_phase
	return self
