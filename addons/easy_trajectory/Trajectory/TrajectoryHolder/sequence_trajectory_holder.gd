@tool
extends TrajectoryHolder
class_name SequenceTrajectoryHolder

##序列轨迹容器，在此容器下的轨迹，按下标从小到大顺序依次迭代

##在SequenceTrajectoryHolder中，除了最后一段，其余的轨迹均应该具有ending_phase
##否则后面的轨迹将会被无视

var current_traj : int = 0

#多态注册机制
static func _static_init() -> void:
	var validator := func(_p : Dictionary):
		for mk in _p:
			if not _p[mk].has("type") or not _p[mk].has("param") or not _p[mk].type is String or not _p[mk].param is Dictionary:
				return false
		return true
		
	BaseTrajectory._register(
		"sequence_holder",
		func(_p : Dictionary):
			var trajs : Array[BaseTrajectory]
			for unit_tr in _p:
				trajs.append(
					BaseTrajectory.create(
						_p[unit_tr].type,
						_p[unit_tr].param
					)
				)
			return SequenceTrajectoryHolder.new(trajs),
		validator
	)

func _init(trajectories : Array[BaseTrajectory] = []) -> void:
	_holder = trajectories.duplicate()
	for item in _holder:
		item.ended.connect(
			func():
				ending_cnt += 1
				current_traj += 1
		)

func evaluate(delta : float) -> Vector2:
	if not _ended and _valid:
		return _holder[current_traj].evaluate(delta)
	else:
		return Vector2.ZERO
		
func update(delta : float):
	if not _ended and _valid:
		_holder[current_traj].update(delta)
