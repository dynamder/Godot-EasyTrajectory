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
		if value:
			ended.emit()
#endregion

#region 内置变换
var embed_transform: Transform2D = Transform2D.IDENTITY
#endregion

#region 多态注册机制
var _meta_type : String
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

#region 轨迹重置和重定义函数，子类需要进行赋值
##重置函数，重置参数应当在对象构造时bind到此函数上
var _resetter := func(): return

##重定义函数，改变轨迹的部分参数并重置轨迹状态，在此函数中需要重新bind _resetter的参数
var _redefiner := func(_p): return
#endregion

##更新轨迹内部参数,调用evaluate前应先调用update
func update(delta : float):
	pass

##给出用于实体移动的位移矢量
func evaluate(delta : float) -> Vector2:
	return Vector2.ZERO

##设置内置轨迹变换
func set_embed_transform(transform_2d: Transform2D):
	self.embed_transform = transform_2d

##轨迹重置函数
func reset() -> void:
	_progress = 0.0
	_last_progress = 0.0
	_valid = true
	_ended = false
	_resetter.call()

##重定义函数，传入字典作为重置参数(格式类似工厂函数)
func redefine(args : Dictionary):
	if not _registry[_meta_type].validator.call(args):
		push_error("EasyTrajectory: Invalid redefine parameters %s" % args)
		return
	_redefiner.call(args)
	reset()

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
	instance._meta_type = type_name
	return instance
	
		
