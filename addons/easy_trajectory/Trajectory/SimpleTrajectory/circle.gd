@tool
extends BaseTrajectory
class_name CircleTrajectory

##CircleTrajectory的ending_phase由角位移表示

var radius : float
var angle : float:
	set(value):
		_last_phase = angle
		angle = value

var _last_phase : float
var angular_speed : float
var angular_acceleration : float

##参数接受函数
func take_param(radius : float, angular_speed : float, angle : float = 0, angular_acceleration : float = 0, ending_phase : float = -1):
	self.radius = radius
	self.angle = deg_to_rad(angle)
	self.angular_speed = deg_to_rad(angular_speed)
	self.angular_acceleration = deg_to_rad(angular_acceleration)
	self._ending_phase = deg_to_rad(ending_phase)

func take_param_dict(_p : Dictionary):
	take_param(
		_p.radius,
		_p.angular_speed,
		0 if not _p.has("angle") else _p.angle,
		0 if not _p.has("angular_acceleration") else _p.angular_acceleration,
		-1 if not _p.has("ending_phase") else _p.ending_phase
	)


#多态注册机制
static func _static_init() -> void:
	var validator := func(_p : Dictionary):
		return (
			_p.has("radius") and _p.radius is float and 
			_p.has("angular_speed") and _p.angular_speed is float and 
			((_p.has("angle") and _p.angle is float) or not _p.has("angle")) and 
			((_p.has("angular_acceleration") and _p.angular_acceleration is float) or not _p.has("angular_acceleration")) and 
			((_p.has("ending_phase") and _p.ending_phase is float) or not _p.has("ending_phase"))
		)
	
	_register(
		"circle",
		func(_p : Dictionary):
			return CircleTrajectory.new(
				_p.radius,
				_p.angular_speed,
				0 if not _p.has("angle") else _p.angle,
				0 if not _p.has("angular_acceleration") else _p.angular_acceleration,
				-1 if not _p.has("ending_phase") else _p.ending_phase
			),
		validator
	)

##给入参数为角度制,初始化是angle为初相位
func _init(radius : float, angular_speed : float, angle : float = 0, angular_acceleration : float = 0, ending_phase : float = -1):
	take_param(radius, angular_speed, angle, angular_acceleration, ending_phase)
	
	#重置和重定义函数
	self._resetter = Callable(take_param).bind(
		radius,
		angular_speed,
		angle,
		angular_acceleration,
		ending_phase
	)
	self._redefiner = func(_p : Dictionary):
		take_param_dict(_p)
		self._resetter = Callable(take_param).bind(
			_p.radius,
			_p.angular_speed,
			0 if not _p.has("angle") else _p.angle,
			0 if not _p.has("angular_acceleration") else _p.angular_acceleration,
			-1 if not _p.has("ending_phase") else _p.ending_phase
		)
	
func evaluate(delta : float) -> Vector2:
	if not _ended and _valid:	
		return self.embed_transform * (radius * (Vector2(cos(angle), sin(angle)) - Vector2(cos(_last_phase), sin(_last_phase))))
	else:
		return Vector2.ZERO

func update(delta : float):
	if not _ended and _valid:
		angle += angular_speed * delta
		angular_speed += angular_acceleration * delta
		if not _ending_phase == -1:
			_progress += (angle - _last_phase) / _ending_phase
