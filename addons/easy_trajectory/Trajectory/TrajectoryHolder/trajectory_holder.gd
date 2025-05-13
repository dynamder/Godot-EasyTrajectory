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

##信号连接器，决定当子轨迹ended信号发出时，要进行什么操作
var _connector := func(item : BaseTrajectory):
	return

##结束信号连接器
var holder_connector := func(item : BaseTrajectory):
	_connector.call(item)
	item.ended.connect(
		func(): 
			ending_cnt += 1
	)
	

##将所有子轨迹连接至holder_connector
func connect_ended_signal():
	for item in _holder:
		holder_connector.call(item)

##重载holder子类的reset，redefine
func reset() -> void:
	_progress = 0.0
	_last_progress = 0.0
	_valid = true
	_ended = false
	ending_cnt = 0
	for item in _holder:
		item.reset()
	_resetter.call()

##holder类型的字典参数基本验证
func _validate_holder(_p : Dictionary) -> bool:
	return (_p.has("type") and _p.type is String and
			_p.has("param") and _p.param is Dictionary)

func redefine(args : Dictionary):
	_holder.clear()
	for mk in args:
		if not _validate_holder(args[mk]):
			push_error("EasyTrajectory: Invalid holder redefine parameters %s" % args[mk])
			continue
		if not _registry[args[mk].type].validator.call(args[mk].param):
			push_error("EasyTrajectory: Invalid holder redefine parameters %s" % args[mk].param)
		_holder.append(
			BaseTrajectory.create(
				args[mk].type,
				args[mk].param
			)
		)
		holder_connector.call(_holder[-1])
	
	_redefiner.call(args)
	reset()
	
func _init(trajectories : Array[BaseTrajectory] = []):
	_holder = trajectories.duplicate()
	connect_ended_signal()
				
func update(delta : float):
	pass

func evaluate(delta : float) -> Vector2:
	return Vector2.ZERO

	

	
