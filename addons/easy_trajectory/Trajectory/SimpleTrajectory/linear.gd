@tool
extends BaseTrajectory
class_name LinearTrajectory

##LinearTrajectory的ending_phase由长度表示

var speed : float
var acceleration : float
var direction : float: ##用角度表示
	set(value):
		direction = value
		var rad = deg_to_rad(value)
		_vec_direction = Vector2(cos(rad),sin(rad))
		
var _vec_direction : Vector2



#多态注册机制
static func _static_init() -> void:
	var validator := func(_p : Dictionary):
		return (
			_p.has("speed") and _p.speed is float and
			_p.has("direction") and _p.direction is float and 
			((_p.has("acceleration") and _p.acceleration is float) or not _p.has("acceleration")) and
			((_p.has("ending_phase") and _p.ending_phase is float) or not _p.has("ending_phase"))
		)
	
	BaseTrajectory._register(
		"linear",
		func(_p) :
			return LinearTrajectory.new(
				_p.speed,
				_p.direction,
				0 if not _p.has("acceleration") else _p.acceleration,
				-1 if not _p.has("ending_phase") else _p.ending_phase
			),
		validator
	)
##属性更新函数
func take_param(speed : float, direction : float, acceleration : float = 0, ending_phase : float = -1):
	self.speed = speed
	self.direction = direction
	self.acceleration = acceleration
	self._ending_phase = ending_phase

func take_param_dict(_p : Dictionary):
	self.speed = _p.speed
	self.direction = _p.direction
	self.acceleration = 0 if not _p.has("acceleration") else _p.acceleration
	self._ending_phase = -1 if not _p.has("ending_phase") else _p.ending_phase

##TODO: resetter and redefiner
func _init(speed : float, direction : float, acceleration : float = 0, ending_phase : float = -1) -> void:
	take_param(speed, direction, acceleration, ending_phase)
	
	#resetter and redefiner
	self._resetter = Callable(take_param).bind(speed, direction, acceleration, ending_phase)	
	self._redefiner = func(_p) :
		take_param_dict(_p)
		self._resetter = Callable(take_param).bind(
			_p.speed,
			_p.direction,
			0 if not _p.has("acceleration") else _p.acceleration,
			-1 if not _p.has("ending_phase") else _p.ending_phase
		)
		
	
	
func evaluate(delta : float) -> Vector2:
	if not _ended and _valid:
		return self.embed_transform * (speed * delta * _vec_direction)
	else:
		return Vector2.ZERO
			
func update(delta : float):
	if not _ended and _valid:
		speed += acceleration * delta
		if not _ending_phase == -1:
			_progress += (speed * delta * _vec_direction).length() / _ending_phase
