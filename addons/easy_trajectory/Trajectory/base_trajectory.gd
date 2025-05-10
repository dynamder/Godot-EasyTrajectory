@tool
extends RefCounted
class_name BaseTrajectory

#region 轨迹相位终止相关
##若ending_phase被指定，_progress表示当前的进程
var _progress : float = 0:
	set(value):
		_last_progress = _progress
		_progress = value
		if _progress >= 1.0:
			_progress = 1.0
			_valid = false
			if not _ended:
				_ended = true
		elif _progress < 0:
			_progress = 0
			
##轨迹终止位，-1表示不终止
var _ending_phase : float

var _last_progress : float

signal ended

var _valid : bool = true
var _ended : bool = false:
	set(value):
		ended.emit()
#endregion

#region 多态注册机制
static var _registry := {}
##合法的注册表格式如下：
"""
{
	"type_name": {
		"constructor" : _constructor,
		"validator" : _validator
	}
}
"""
#endregion

##更新轨迹内部参数,调用evaluate前应先调用update
func update(delta : float):
	pass

##给出用于实体移动的位移矢量
func evaluate(delta : float) -> Vector2:
	return Vector2.ZERO

static func _register(type_name : String, _constructor : Callable, _validator : Callable = func(_p): return true):
	_registry[type_name] = {
		"constructor": _constructor,
		"validator": _validator
	}
	
static func create(type_name : String, param : Dictionary = {}) -> BaseTrajectory:
	if not _registry.has(type_name):
		push_error("Unregistered Trajectory Type: " + type_name)
		return null
	var traj_factory = _registry[type_name]
	if not traj_factory.validator.call(param):
		push_error("Invalid Trajectory Parameter:", param)
		return null
		
	var instance = traj_factory.constructor.call(param)
	assert(instance is BaseTrajectory, "Class Type Check Failed")
	return instance
	
		
