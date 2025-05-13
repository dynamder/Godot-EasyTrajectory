# EasyTrajectory

[ENGLISH](readme_en.md)           [简体中文](readme.md)

EasyTrajectory是一个针对**2D场景**，用于快速，轻松的创建诸如弹道，敌人移动之类的轨迹的插件，完全由GDscript编写。可以通过不同轨迹类型的组合，简单，灵活地创建出较为复杂的轨迹

------

将addons文件夹复制到你的godot项目即可完成安装

## 快速上手

要创建一个轨迹，有两种方法：

- 使用new()方法
- 使用工厂函数create()

下面以创建一条倾角30°的直线轨迹为例，物体在此轨迹上的移动速度为30

**注意：**Godot的坐标系是计算机图形学中常用的坐标系，因此，30°是从x轴正方向顺时针旋转30°而非像数学中那样逆时针旋转30°

### new()

```gdscript
var traj = LinearTrajectory.new(30.0,30.0)
```

### create()

```gdscript
var traj = BaseTrajectory.create(
		"linear",
		{
			"speed" : 30.0,
			"direction" : 30.0
		}
	)
```

在使用工厂函数时，第一个参数为轨迹类型，第二个参数时轨迹的参数，键名与轨迹的对应属性名相同



**建议**：总是使用工厂函数create()的方式，除非需要快速对某些轨迹形状进行测试



### 使用轨迹

要使用轨迹，需要在 _process 方法或是 _physics_process 方法中进行如下操作：

```gdscript
func _process(delta : float):
	traj.update(delta) #更新轨迹状态
	position += traj.evaluate(delta) #迭代节点位置
```

- update(delta) 用于更新轨迹内部属性，应当在 evaluate(delta) 前调用

- evaluate(delta) 返回一个 Vector2 类型的位移矢量，与节点的position属性相加即可让节点沿轨迹移动

**注意：**轨迹的坐标位置并**不是绝对**的，EasyTrajectory定义的轨迹只是定义一个轨迹的形状，轨迹的**起点**为节点开始迭代时的**自身位置**。从效果上来看，对哪个节点使用EasyTrajectoy的轨迹迭代，轨迹使用的就是该节点的**局部坐标系**



### 重置与重定义轨迹

- 重置轨迹至初始状态：

```gdscript
traj.reset()
```

**注**：如上所述，这并不能让被迭代的对象回到原来的位置



- 重定义轨迹（以LinearTrajectory为例）：

```
traj.redefine(
	{
		"speed" : 50.0,
		"direction" : 20.0
	}
)
```

重定义的轨迹与原轨迹类型相同，且重定义的参数只能由字典方式指定（就像工厂函数那样）

**注**：在TrajectoryHolder及其子类中，子轨迹的类型在重定义时可以改变（见下文）



EasyTrajectory提供了集中默认集成的轨迹类型，通过这些轨迹类型及其组合，能满足大部分的基本功能，下面将介绍EasyTrajectory中自带的轨迹类型

------



## 默认轨迹类型

类型清单列表（括号内为工厂函数中需要使用的名字）：

- **LinearTrajectory** (linear)
- **CircleTrajectory** (circle)
- **VelAccelTrajectory** (velaccel)
- **BezierTrajectory** (bezier)
- **SequenceTrajectoryHolder** (sequence_holder)
- **BlendTrajectoryHolder** (blend_holder)



**注：**标有（可选）的属性，在创建时含默认参数，可以不提供



### BaseTrajectory

所有轨迹的基类，具有如下的常用属性：

```gdscript
_progress : float #轨迹进程，范围为 0.0 ~ 1.0 ，如果轨迹具有一个结束状态，该属性表明了轨迹当前的迭代进程
signal ended #结束信号，如果轨迹存在结束状态，则轨迹迭代至结束状态时，该信号会发出
```





### LinearTrajectory (linear)

直线轨迹类型，具有如下属性：

```gdscript
speed : float #速率
acceleration : float #加速度（可选），默认值 0 
direction : float: #方向角，用角度制表示
ending_phase : float #结束状态，此处由直线长度定义 （可选）， 默认值 -1
```

在工厂函数中，按如下格式创建(后续仅列出必要属性)：

```gdscript
BaseTrajectory.create(
		"linear",
		{
			"speed" : 10.0,
			"acceleration" : 0.0,
			"direction" : 20.0,
			"ending_phase" : 60.0
		}
	)
```



### CircleTrajectory (circle)

圆形轨迹类型，具有如下属性（角度相关的均为角度制）：

```gdscript
radius : float #半径
angle : float #当前相位 （可选）， 默认值 0，在创建时设置此参数改变节点在轨迹上的初始位置
angular_speed : float #角速度
angular_acceleration : float #角加速度 （可选）， 默认值 0
ending_phase : float #结束状态，此处由角位移定义 （可选）， 默认值 -1
```

在工厂函数中，按如下格式创建：

```gdscript
BaseTrajectory.create(
		"circle",
		{
			"radius" : 50.0,
			"angular_speed" : 30.0
		}
	)
```



### VelAccelTrajectory (velaccel)

由一个Vector2 类型的速度和 Vector2 类型的加速度定义，具有如下属性：

```gdscript
velocity : Vector2 #速度
acceleration : Vector2 #加速度 （可选）， 默认值 Vector2.ZERO
ending_phase : float #结束状态，此处由轨迹长度（路程）定义 （可选），默认值 -1
```

在工厂函数中，按如下格式创建：

```gdscript
BaseTrajectory.create(
		"velaccel",
		{
			"velocity" : Vector2(30,0),
			"acceleration" : Vector2(0,50)
		}
	)
```



### BezierTrajectory (bezier)

#### BezierUnit

贝塞尔曲线的基本单元，定义如下：

```gdscript
class BezierUnit:
	var point : Vector2 #点位置
	var ctrl_in : Vector2 #控制向量in （可选）
	var ctrl_out : Vector2 #控制向量out （可选）
```

在构造 BezierUnit 时，ctrl_in 和 ctrl_out 可以不指定，默认为 Vector.ZERO

详细有关贝塞尔曲线的信息，请参照Godot官方文档：[贝塞尔，曲线和路径](https://docs.godotengine.org/zh-cn/4.x/tutorials/math/beziers_and_curves.html)



#### Trajectory

由一系列贝塞尔曲线的控制点定义的轨迹类型，具有如下属性：

```gdscript
_curve : Curve2D #贝塞尔曲线（创建时不用提供）
speed : float #速率
acceleration : float #加速度 （可选）， 默认值 0
```

BezierTrajectory在创建时：

- 需要提供控制点列_points : Array作为第一个参数，其中的类型可以是：

  - BezierUnit

  - Vector2

    - 作为 BezierUnit 的 point 属性

  - Dictionary

    - ```gdscript
      {
      	"point": Vector2(0,0),
      	"in" : Vector2(-10,-10),
      	"out" : Vector2(10,10)
      }
      ```

- BezierTrajectory并没有ending_phase参数，因为贝塞尔曲线通常总是有一个确定的长度。



在工厂函数中，按如下格式创建：

```gdscript
var traj = BaseTrajectory.create(
		"bezier",
		{
			"speed" : 60.0,
			"points": [
				{
					"point": Vector2(226,388),
					"out" : Vector2(284.1,-42.44)
				},
				{
					"point" : Vector2(267,83),
					"in" : Vector2(17.68,137.94),
					"out" : Vector2(-17.68,-137.9)
				},
				{
					"point" : Vector2(0,0),
					"in" : Vector2(236.9,-80.17)
				}
			]
		}
	)
```

**注**：迭代对象在贝塞尔曲线上的速度完全由speed属性决定，与曲线在某点的曲率无关



### TrajectoryHolder

以下是较为特殊的轨迹类型TrajectoryHolder，它们本身不直接定义轨迹，它们包含多条各种类型的轨迹，并以某种方式将这些轨迹组合，这使得创建复杂灵活地轨迹成为可能

因为TrajectoryHolder仅仅包含上述的 ”基本轨迹“，因此它们通常没有额外的属性。TrajectoryHolder中_process属性是无效的，不能通过 _process得知轨迹的迭代进程。但用户仍然可以使用ended信号来获知轨迹是否结束，当TrajectoryHolder中所有轨迹均结束时，ended信号会被发出



**注：**因为EasyTrajectory效果上使用的是迭代对象的**局部坐标系**，因此TrajectoryHolder下包含的的轨迹之间无需满足例如连续等约束条件。



#### SequenceTrajectoryHolder (sequence_holder)

轨迹序列，在此之中的各段轨迹，按顺序从头到尾进行拼接，具有以下额外属性：

```gdscript
current_traj : int #当前轨迹的下标编号
```

SequenceTrajectoryHolder中，可以使用如下代码间接获取轨迹的迭代进程

```gdscript
_holder[current_traj]._process
```

**注：**除了SequenceTrajectoryHolder中最后一段轨迹，其余轨迹理论上应当是具有结束状态的，否则该段轨迹后面的轨迹将会被忽略



在工厂函数中，按如下格式创建：

```gdscript
BaseTrajectory.create(
		"sequence_holder",
		{
			1 : {
				"type" : "linear",
				"param" : {
					"speed" : 30.0,
					"direction" : 40.0,
					"ending_phase" : 100.0
				}
			},
			2 : {
				"type" : "circle",
				"param" : {
					"radius" : 60.0,
					"angular_speed" : 40.0
				}
			}
		}
	)
```

**注：**每一段轨迹前的 “键名”并无任何要求（包括类型要求），可以将键名作为该段轨迹的**注释**使用



#### BlendTrajectoryHolder (blend_holder)

合成轨迹，在此之中的各段轨迹，将会进行运动合成，不具有额外属性

**注：**BlendTrajectoryHolder中的各段轨迹并无任何约束限制，其中的轨迹可以具有结束状态也可以不具有，具有结束状态的轨迹相当于只影响迭代中的一段过程



在工厂函数中，按如下格式创建， 此处将给出一个较为复杂的嵌套Holder轨迹定义，描述一段直线接一段螺旋线：

```gdscript
BaseTrajectory.create(
		"sequence_holder",
		{
			"line" : {
				"type" : "linear",
				"param" : {
					"speed" : 30.0,
					"direction" : 20.0,
					"ending_phase" : 160.0
				}
			},
			"spiral" : {
				"type" : "blend_holder",
				"param" : {
					1 : {
						"type": "linear",
						"param": {
							"speed" : 30.0,
							"direction" : 30.0
						}
					},
					2 : {
						"type": "circle",
						"param": {
							"radius" : 40.0,
							"angular_speed" : 60.0
						}
					}
				}
			}
		}
		
	)
```



## 自定义轨迹类型

以下是EasyTrajectory较为高阶的使用方法，EasyTrajectory允许用户创建自己的轨迹类型，它们使用上与默认轨迹类型完全相同，以下是自定义轨迹类型的步骤



### 创建类型脚本

用户可以继承自任意一个以BaseTrajectory为基类（或其自身）的类型（通常为BaseTrajectory或TrajectoryHolder）,为保证行为一致性，以下方法需要被重载

- ```gdscript
  func update(delta : float):
  ```

- ```gdscript
  func evaluate(delta : float) -> Vector2:
  ```



在update方法中，除了描述轨迹的内部属性，还应当正确的维护**_progress**变量（继承自TrajectoryHolder的除外），以下是LinearTrajectory中的代码示例

```gdscript
func update(delta : float):
	if not _ended and _valid: #轨迹没有结束且有效
		speed += acceleration * delta #更新描述轨迹的内部属性
		if not _ending_phase == -1: #如果定义了结束状态
			_progress += (speed * delta * _vec_direction).length() / _ending_phase #维护_progress变量
```



SequenceTrajectoryHolder中的代码示例：

```gdscript
func update(delta : float):
	if not _ended and _valid:
		_holder[current_traj].update(delta)
```



在evaluate方法中，需要返回一个位移矢量，以下是LinearTrajectory中的代码示例：

```gdscript
func evaluate(delta : float) -> Vector2:
	if not _ended and _valid: #轨迹没有结束且有效
		return speed * delta * _vec_direction #返回位移矢量
	else:
		return Vector2.ZERO #此时轨迹不应该作用，返回Vector2.ZERO
```



以下是SequenceTrajectoryHolder中的代码示例：

```gdscript
func evaluate(delta : float) -> Vector2:
	if not _ended and _valid:
		return _holder[current_traj].evaluate(delta)
	else:
		return Vector2.ZERO
```



**注：**通常来说，用户还需要重载**_init**方法，以在创建轨迹时传入必要的参数



### 支持工厂函数

以上，我们完成了一个新轨迹类型的基本迭代功能，但此时无法通过工厂函数 BaseTrajectory.create() 来创建我们定义的轨迹类型

要支持工厂函数，需要完成以下额外工作：

- 重载 _static_init 方法
- 在插件根目录下的UserConfig/register.json中的 "custom"里，加入类型脚本的脚本路径



#### 重载_static_init方法

在此方法中，需要调用以下方法注册我们的自定义类型

```gdscript
static func _register(type_name : String, _constructor : Callable, _validator : Callable = func(_p): return true):
```

参数解释：

- type_name
  - 工厂函数中的轨迹类型，如前文提到的"linear"，"circle"
- _constructor
  - 构造器，用以实际创建轨迹对象
- _validator
  - 参数验证器，验证传来的参数字典是否合法



以下为LinearTrajectory中的代码示例：

```gdscript
static func _static_init() -> void:
	var validator := func(_p : Dictionary): #定义参数验证器，需要返回bool值，验证成功为true
		return (
			_p.has("speed") and _p.speed is float and
			_p.has("direction") and _p.direction is float and 
			((_p.has("acceleration") and _p.acceleration is float) or not _p.has("acceleration")) and
			((_p.has("ending_phase") and _p.ending_phase is float) or not _p.has("ending_phase"))
		)
	
	#注册函数
	BaseTrajectory._register(
		"linear", #轨迹类型名
		func(_p) : #构造器
			return LinearTrajectory.new(
				_p.speed, #必要参数
				_p.direction,
				0 if not _p.has("acceleration") else _p.acceleration, #处理可选参数
				-1 if not _p.has("ending_phase") else _p.ending_phase
			),
		validator #参数验证器
	)
```



#### 加入脚本路径

由于_static_init方法需要加载脚本（load或preload）时才被调用，因此需要确保在使用工厂函数前，轨迹类型脚本均已被加载。

加载脚本由全局自动脚本 Trajectory/trajectory_register.gd进行，将逐一使用load方法加载配置文件中的所有脚本路径。



配置文件在插件根目录下的UserConfig/register.json中（通常为res://addons/easy_trajectory/UserConfig/register.json），其应该已经存在如下内容：

```json
{
	"default" : [
		"res://addons/easy_trajectory/Trajectory/SimpleTrajectory/linear.gd",
		"res://addons/easy_trajectory/Trajectory/SimpleTrajectory/circle.gd",
		"res://addons/easy_trajectory/Trajectory/ComplexTrajectory/va.gd",
		"res://addons/easy_trajectory/Trajectory/ComplexTrajectory/bezier.gd",
		"res://addons/easy_trajectory/Trajectory/TrajectoryHolder/trajectory_holder.gd",
		"res://addons/easy_trajectory/Trajectory/TrajectoryHolder/sequence_trajectory_holder.gd",
		"res://addons/easy_trajectory/Trajectory/TrajectoryHolder/blend_trajectory_holder.gd"
	],
	"custom" : [
		
	]
}

```

default一栏为插件的默认类型，为方便区分，请将自定义的脚本路径加在custom中



### 支持重置与重定义

要支持重置与重定义功能，需要一些额外处理

#### 重置

重置功能函数：

```gdscript
#BaseTrajectory
_resetter : Callable
```

赋值该属性以定义重置器，重置功能需要轨迹被创建时的原始参数，此处建议使用bind()方法绑定原始参数



以LinearTrajectory为例：

```gdscript
func take_param(speed : float, direction : float, acceleration : float = 0, ending_phase : float = -1):
	self.speed = speed
	self.direction = direction
	self.acceleration = acceleration
	self._ending_phase = ending_phase

func _init(speed : float, direction : float, acceleration : float = 0, ending_phase : float = -1) -> void:
	...
	self._resetter = Callable(take_param).bind(speed, direction, acceleration, ending_phase)
	...
```

**注**：基本轨迹属性，如 _progress, _last_progress,  _valid,  _ended 不需要在重置器中维护



#### 重定义

重定义功能函数：

```gdscript
#BaseTrajectory
_redefiner := func(_p): return
```

赋值该属性以定义重定义器，重定义器接受一个字典，从中提取必要参数

**注**：

- 你无需在_redefiner中校验字典数据，校验在调用redefine() 时自动完成
- 在_redefiner中，请重新bind()  _resetter中的参数



以LinearTrajectory为例：

```gdscript
func take_param_dict(_p : Dictionary):
	self.speed = _p.speed
	self.direction = _p.direction
	self.acceleration = 0 if not _p.has("acceleration") else _p.acceleration
	self._ending_phase = -1 if not _p.has("ending_phase") else _p.ending_phase
	
func _init(speed : float, direction : float, acceleration : float = 0, ending_phase : float = -1) -> void:
	...
	self._redefiner = func(_p) :
		take_param_dict(_p)
		self._resetter = Callable(take_param).bind(
			_p.speed,
			_p.direction,
			0 if not _p.has("acceleration") else _p.acceleration,
			-1 if not _p.has("ending_phase") else _p.ending_phase
		)
	...
```



### 针对TrajectoryHolder类型

TrajectoryHolder类型有一个额外属性，用于在子轨迹结束时执行相应操作

```gdscript
var _connector := func(item : BaseTrajectory):
	return
```



以SequenceTrajectoryHolder为例：

```gdscript
func _init(trajectories : Array[BaseTrajectory] = []) -> void:
	self._connector = func(item : BaseTrajectory):
		item.ended.connect(
			func():
				if not ending_cnt >= _holder.size():
					current_traj += 1				
		)
	super(trajectories)
	...
```

**注**：继承自TrajectoryHolder的类型，请一定调用**父级**（TrajectoryHolder）的 **_init()** 方法，否则会导致信号异常，轨迹无法结束



TrajectoryHolder 重载了reset() 和 redefine() 方法，能正确的处理ended信号连接和子轨迹的构造，因此除非特殊需求，无需重新编写_resetter 和 _redefiner。如果定义了 _redefiner, 也无需重新bind() _resetter



在redefine() 方法中，_redefiner会在信号连接处理完毕后，reset() 方法之前被调用

------

至此，我们自定义的轨迹类型应当可以像默认类型那样工作了，恭喜~

------



## 一些后话

感谢能读到这里，这款插件仍然处于初期开发阶段，仍有些功能不完善，也有一些实现方式比较粗糙，后续会更新以下功能：

- 参数突变（轨迹运行时更改参数值，保留目前的状态）
- 集成的轨迹对象池，用以支持诸如弹幕地狱游戏频繁，大量创建轨迹的需求



再次感谢使用，支持本插件的所有人 ღ( ´･ᴗ･` )~