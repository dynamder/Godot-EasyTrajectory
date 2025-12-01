extends BaseDictBuilder
class_name BezierTrajDict

var points: Array
var speed: float
var acceleration: float = 0

func build() -> Dictionary:
	return {
		"points": points,
		"speed": speed,
		"acceleration": acceleration
	}
	
func set_points(set_points: Array) -> BezierTrajDict:
	self.points = set_points
	return self

func set_speed_accel(set_speed: float, set_acceleration: float = 0) -> BezierTrajDict:
	self.speed = set_speed
	self.acceleration = set_acceleration
	return self
