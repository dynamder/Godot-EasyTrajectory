@tool
extends BaseTrajectory
class_name BezierTrajectory

##BezierTrajectory的ending_phase由总路程表示

var _curve : Curve2D
var _baked_points : PackedVector2Array
var _length : float
##暂时留着，后续增加不使用bake
var use_baked : bool = true

var speed : float
var acceleration : float

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
	self.speed = speed
	self.acceleration = acceleration
	_curve = Curve2D.new()
	for point in points:
		_curve.add_point(point)

	_baked_points = _curve.get_baked_points()
	_length = _curve.get_baked_length()

##根据相对百分比位置（0.0-1.0）获得曲线上的点
func _bezier(t: float) -> Vector2:
	if _baked_points.size() > 0:
		# 使用预计算点优化性能
		var point_t : float = t * _baked_points.size()
		var l_index : int = max(0,floor(point_t))
		var r_index : int = min(ceil(point_t),_baked_points.size() - 1)
		
		return _baked_points[l_index].lerp(
			_baked_points[r_index],
			point_t - int(point_t)
		)
	
	else:
		return Vector2.ZERO


func evaluate(delta : float) -> Vector2:
	if not _ended and _valid:
		return _bezier(_progress) - _bezier(_last_progress)
	else:
		return Vector2.ZERO

func update(delta : float):
	if not _ended and _valid:
		_progress += speed * delta / _length
		speed += acceleration * delta
	
