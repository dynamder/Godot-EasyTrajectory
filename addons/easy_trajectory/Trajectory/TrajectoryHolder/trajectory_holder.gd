@tool
extends BaseTrajectory
class_name TrajectoryHolder

var _holder : Array[BaseTrajectory]
##计数器，所有包含的轨迹均结束才算结束
var ending_cnt : int:
	set(value):
		ending_cnt = value
		if ending_cnt == _holder.size():
			_valid = false
			_ended = true
			
##TrajectoryHolder没有多态注册机制，不应该被直接创建，仅作为抽象基类使用

func _init(trajectories : Array[BaseTrajectory] = []):
	_holder = trajectories.duplicate()
	for item in _holder:
		item.ended.connect(func(): ending_cnt += 1)
	
func update(delta : float):
	pass

func evaluate(delta : float) -> Vector2:
	return Vector2.ZERO

##TODO:实现多态机制
func add(trajectory_dict : Dictionary):
	pass
	

	
