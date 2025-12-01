@tool
extends BaseTrajectory
class_name BezierTrajectory

##贝塞尔曲线单元，由一个曲线上的点，两个控制向量组成
class BezierUnit:
	var point : Vector2
	var ctrl_in : Vector2
	var ctrl_out : Vector2
	
	func _init(point : Vector2, ctrl_in : Vector2 = Vector2.ZERO, ctrl_out : Vector2 = Vector2.ZERO) -> void:
		self.point = point
		self.ctrl_in = ctrl_in
		self.ctrl_out = ctrl_out

##BezierTrajectory的ending_phase由总路程表示

var _curve : Curve2D
var _baked_points : PackedVector2Array
var _length : float
##暂时留着，后续增加不使用bake
var use_baked : bool = true

var speed : float
var acceleration : float

##统一数据转换，转换为贝塞尔曲线单元
func unit_caster(points : Array) -> Array[BezierUnit]:
	var unit : Array[BezierUnit] = []
	for item in points:
		if item is BezierUnit:
			unit.append(item)
		elif item is Vector2:
			unit.append(
				BezierUnit.new(item)
			)
		elif item is Dictionary:
			if not (item.has("point") and item.point is Vector2 and
			((item.has("in") and item.in is Vector2) or not item.has("in")) and 
			((item.has("out") and item.out is Vector2) or not item.has("out"))):
				push_error("EasyTrajectory: Invalid Bezier trajectory point dict %s" % item)
				return []
			unit.append(
				BezierUnit.new(
					item.point, 
					Vector2.ZERO if not item.has("in") else item.in, 
					Vector2.ZERO if not item.has("out") else item.out
				)
			)
		else:
			push_error("EasyTrajectory: Invalid Bezier trajectory point %s" % item)
			return []
	return unit

#参数更新函数
func take_param(points : Array, speed : float, acceleration : float = 0):
	self.speed = speed
	self.acceleration = acceleration
	
	var unit = unit_caster(points)
	_curve.clear_points()
	for p in unit:
		_curve.add_point(
			p.point,
			p.ctrl_in,
			p.ctrl_out
		)

	_baked_points = _curve.get_baked_points()
	_length = _curve.get_baked_length()

func take_param_dict(_p : Dictionary):
	take_param(
		_p.points,
		_p.speed,
		0 if not _p.has("acceleration") else _p.acceleration
	)


static func _static_init() -> void:
	var validator := func(_p : Dictionary):
		return (
			_p.has("points") and _p.points is Array and
			_p.has("speed") and _p.speed is float and 
			((_p.has("acceleration") and _p.acceleration is float) or not _p.has("acceleration"))
		)
	
	BaseTrajectory._register(
		"bezier",
		func(_p):
			return BezierTrajectory.new(
				_p.points,
				_p.speed,
				0 if not _p.has("acceleration") else _p.acceleration
			),
		validator
	)


func _init(points : Array, speed : float, acceleration : float = 0) -> void:
	_curve = Curve2D.new()
	take_param(points, speed, acceleration)
	self._resetter = Callable(take_param).bind(points, speed, acceleration)
	self._redefiner = func(_p):
		take_param_dict(_p)
		self._resetter = Callable(take_param).bind(
			_p.points,
			_p.speed,
			0 if not _p.has("acceleration") else _p.acceleration
		)

##根据相对百分比位置（0.0-1.0）获得曲线上的点，保证匀速
func _bezier(t: float) -> Vector2:
	
	if _baked_points.size() > 0:
		return _curve.sample_baked(t * _length)
	
	else:
		return Vector2.ZERO


func evaluate(delta : float) -> Vector2:
	if not _ended and _valid:
		return self.embed_transform * (_bezier(_progress) - _bezier(_last_progress))
	else:
		return Vector2.ZERO

func update(delta : float):
	if not _ended and _valid:
		_progress += speed * delta / _length
		speed += acceleration * delta
	
