@tool
extends TrajectoryHolder
class_name BlendTrajectoryHolder

##混合轨迹容器，在此容器下的轨迹会被合成


#多态注册机制
static func _static_init() -> void:
	var validator := func(_p : Dictionary):
		for mk in _p:
			if not _p[mk].has("type") or not _p[mk].has("param") or not _p[mk].type is String or not _p[mk].param is Dictionary:
				return false
		return true
		
	BaseTrajectory._register(
		"blend_holder",
		func(_p : Dictionary):
			var trajs : Array[BaseTrajectory]
			for unit_tr in _p:
				trajs.append(
					BaseTrajectory.create(
						_p[unit_tr].type,
						_p[unit_tr].param
					)
				)
			return BlendTrajectoryHolder.new(trajs),
		validator
	)

func evaluate(delta : float) -> Vector2:
	if not _ended and _valid:
		var sum_vec := Vector2.ZERO
		for item in _holder:
			sum_vec += item.evaluate(delta)
		return  self.embed_transform * sum_vec
	else:
		return Vector2.ZERO

func update(delta : float):
	if not _ended and _valid:
		for item in _holder:
			item.update(delta)
