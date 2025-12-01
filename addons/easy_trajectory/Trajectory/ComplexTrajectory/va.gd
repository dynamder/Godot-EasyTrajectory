@tool
extends BaseTrajectory
class_name VelAccelTrajectory

##VelAccelTrajectory的ending_phase由总路程表示

var velocity : Vector2
var acceleration : Vector2

func take_param(velocity : Vector2, acceleration : Vector2 = Vector2.ZERO, ending_phase :float = -1):
	self.velocity = velocity
	self.acceleration = acceleration
	self._ending_phase = ending_phase
	
func take_param_dict(_p : Dictionary):
	take_param(
		_p.velocity,
		Vector2.ZERO if not _p.has("acceleration") else _p.acceleration,
		-1 if not _p.has("ending_phase") else _p.ending_phase
	)

static func _static_init() -> void:
	var validator := func(_p : Dictionary):
		return (
			_p.has("velocity") and _p.velocity is Vector2 and 
			((_p.has("acceleration") and _p.acceleration is Vector2) or not _p.has("acceleration")) and
			((_p.has("ending_phase") and _p.ending_phase is float) or not _p.has("ending_phase"))
		)
	
	BaseTrajectory._register(
		"velaccel",
		func(_p):
			return VelAccelTrajectory.new(
				_p.velocity,
				Vector2.ZERO if not _p.has("acceleration") else _p.acceleration,
				-1 if not _p.has("ending_phase") else _p.ending_phase
			),
		validator
	)

func _init(velocity : Vector2, acceleration : Vector2 = Vector2.ZERO, ending_phase :float = -1):
	take_param(velocity,acceleration,ending_phase)
	
	self._resetter = Callable(take_param).bind(
		velocity,
		acceleration,
		ending_phase
	)
	self._redefiner = func(_p : Dictionary):
		take_param_dict(_p)
		self._resetter = Callable(take_param).bind(
			_p.velocity,
			Vector2.ZERO if not _p.has("acceleration") else _p.acceleration,
			-1 if not _p.has("ending_phase") else _p.ending_phase
		)
	
func evaluate(delta : float) -> Vector2:
	if not _ended and _valid:	
		return self.embed_transform * (delta * velocity)
	else:
		return Vector2.ZERO
	
func update(delta : float):
	if not _ended and _valid:
		velocity += acceleration * delta
		if not _ending_phase == -1:
			_progress += (delta * velocity).length() / _ending_phase
