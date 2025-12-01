# EasyTrajectory

[ENGLISH](readme_en.md)           [简体中文](readme.md)

EasyTrajectory is a **2D scene** plugin for quickly and easily creating trajectories like bullet paths and enemy movements. Written entirely in GDScript, it allows flexible creation of complex trajectories through combination of different trajectory types.

------

copy the addons folder to your godot project to complete the installation

## Quick Start

There are two methods to create a trajectory:

- Using the new() method
- Using the factory function create()

Example: Create a straight line trajectory with 30° tilt angle and movement speed 30.

**Note:** Godot uses the standard computer graphics coordinate system where 30° is measured clockwise from the positive x-axis, unlike the mathematical convention.

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

When using the factory function, the first parameter is the trajectory type, and the second is a dictionary of parameters matching the trajectory's property names.

Argument dictionary helper class can be used to construct the dictionary.



**Suggestion**: Always use the create() factory method, unless you need to quickly test some trajectory prototypes



### Using Trajectories

In `_process` or `_physics_process`:

```gdscript
func _process(delta : float):
    traj.update(delta) # Update trajectory state
    position += traj.evaluate(delta) # Update node position
```

- `update(delta)` updates internal properties and should be called before `evaluate(delta)`.
- `evaluate(delta)` returns a Vector2 displacement to apply to the node's position.

**Note:** Trajectories are defined in the **local coordinate system** of the node using them. The starting point is the node's initial position.



### Reset and Redefine trajectory

- reset the trajectory to the initial state

  ```gdscript
  traj.reset()
  ```

  **Note**: As mentioned above (local coordinate system), the reset() method can't reset the node's position

- redefine trajectory (Example for redefining LinearTrajectory)

  ```gdscript
  traj.redefine(
  	{
  		"speed" : 50.0,
  		"direction" : 20.0
  	}
  )
  ```

  the redefined trajectory has the same type of the original trajectory, and the redefine() parameter can only be given in Dictionary (like what we do in the factory function)

  **Note**： In TrajectoryHolder and its subclasses, the type of sub trajectory can be changed when redefining (will mention in the following paragraph)

### Embed Transform

There is an Transform2D attribute "embed_transform" in BaseTrajectory, it will transform the trajectory accordingly.

This transform is lazy, only when evaluate() is called, the returned vector will be transformed.

------

## Built-in Trajectory Types

Type list (factory names in parentheses):
- **LinearTrajectory** (linear)
- **CircleTrajectory** (circle)
- **VelAccelTrajectory** (velaccel)
- **BezierTrajectory** (bezier)
- **SequenceTrajectoryHolder** (sequence_holder)
- **BlendTrajectoryHolder** (blend_holder)

properties marked as **Optional**  have default values.

### BaseTrajectory
Base class for all trajectories:
```gdscript
_progress : float # Trajectory progress (0.0~1.0), if the trajectory has an ending state, it will be valid
signal ended # Emitted when trajectory finishes
```

### LinearTrajectory (linear)
Straight line trajectory:
```gdscript
speed : float # Speed
acceleration : float # Acceleration (optional, default 0)
direction : float # Direction angle (degrees)
ending_phase : float # End condition by length (optional, default -1)
```

Factory example:
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

Or use argument dictionary builder:

```gdscript
var linear_traj_dict := LinearTrajDict.new().set_speed_accel(
		10
	).set_direction(
		20
	).set_ending_phase(
		60
	).build()

BaseTrajectory.create(
	"linear",
	linear_traj_dict
)
```



### CircleTrajectory (circle)

Circular trajectory (angles in degrees):
```gdscript
radius : float # Radius
angle : float # current phase (optional, default 0), can be set when initialized for initial phase
angular_speed : float # Angular speed
angular_acceleration : float # Angular acceleration (optional, default 0)
ending_phase : float # End condition by angular displacement (optional, default -1)
```

Factory example:
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

Defined by velocity and acceleration vectors:
```gdscript
velocity : Vector2 # Velocity
acceleration : Vector2 # Acceleration (optional, default Vector2.ZERO)
ending_phase : float # End condition by trajectory length (optional, default -1)
```

Factory example:
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

the basic unit of a Bezier curve, defined as followed:

```gdscript
class BezierUnit:
	var point : Vector2 #position
	var ctrl_in : Vector2 #control vector in （optional）
	var ctrl_out : Vector2 #control vector out （optional）
```

When construcing BezierUnit, the *ctrl_in* and the *ctrl_out* can be left empty, and the default value is Vector.ZERO

For more information about the bezier curve, please refer to the Godot Official Document: [Beziers, curves and paths](https://docs.godotengine.org/en/stable/tutorials/math/beziers_and_curves.html)



#### Trajectory

Bezier curve trajectory:

```gdscript
_curve : Curve2D # Bezier curve (auto-generated)
speed : float # Speed
acceleration : float # Acceleration (optional, default 0)
```

When creating:

- point array *_points : Array* should be provided, the following type is allowed:

  - BezierUnit

  - Vector2

    - treated as the *point* attribute in BezierUnit

  - Dictionary

    - ```gdscript
      {
      	"point": Vector2(0,0),
      	"in" : Vector2(-10,-10),
      	"out" : Vector2(10,10)
      }
      ```

- There is no *ending_phase* as Bezier curve always has an finite length



Factory example (requires `points` array):

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

**Note**: the node's speed on the BezierTrajectory is completely determined by the *speed* attribute, and has no relation with the point's curvature.

### TrajectoryHolder Types

Special types that combine other trajectories:

- _process will be invalid in TrajectoryHolder and all its subclasses, but the "ended" signal is still valid
- the "ended" signal will be emitted if all the trajectory inside is ended



**Note:** There is no constraint in TrajectoryHolder, as we use a **local coordination** so the position can't mutate



#### SequenceTrajectoryHolder (sequence_holder)

Plays trajectories sequentially:
```gdscript
current_traj : int # Index of current trajectory
```

Specially, you could use the following code to access the iteration process indirectly:

```gdscript
_holder[current_traj]._process
```



**Note:** Except for the last trajectory, every trajectory inside should have an end conditon, or the following trajectories will be ignored



Factory example:

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

**Note:** There are no special requirements for the key name of each trajectory, so you can use the key name as an annotation, like what is shown later



#### BlendTrajectoryHolder (blend_holder)

Blends multiple trajectories simultaneously. Example of a line followed by a spiral path:

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

**Note:** There is no special constraint inside a BlendTrajectoryHolder, some can have an end condition and others not. If the trajectory has an end condition, it will only be in effect when it is not ended.

------

## Custom Trajectory Types
Custom types can be defined and act just like the built-in types. Follow the steps below.

### Create Script

Extend from `BaseTrajectory` or its subclasses (Usually BaseTrajectory or TrajectoryHolder). Required overrides:
```gdscript
func update(delta: float):
func evaluate(delta: float) -> Vector2:
```

- _progress property should be maintained correctly unless the type derived from a TrajectoryHolder
- a Vector2 displacement must be returned in the evaluate() method

Example (LinearTrajectory):

```gdscript
func update(delta : float):
	if not _ended and _valid: #the trajectory is not ended and still valid
		speed += acceleration * delta #update inner properties related to trajectory itself
		if not _ending_phase == -1: #if the end condition is defined
			_progress += (speed * delta * _vec_direction).length() / _ending_phase #maintain _progress

func evaluate(delta : float) -> Vector2:
	if not _ended and _valid: #the trajectory is not ended and still valid
		return speed * delta * _vec_direction #return the Vector2 displacement
	else:
		return Vector2.ZERO #the trajectory here should not apply, so return Vector2.ZERO
```



Example (SequenceTrajectoryHolder):

```gdscript
func update(delta : float):
	if not _ended and _valid:
		_holder[current_traj].update(delta)

func evaluate(delta : float) -> Vector2:
	if not _ended and _valid:
		return _holder[current_traj].evaluate(delta)
	else:
		return Vector2.ZERO
```

**Note：**In most cases, the _init method should be override to accept necessary parameters



### Factory Support

To use the BaseTrajectory.create(), we need to :

- Override `_static_init` to register type
- Add script path to `register.json` (UserConfig/register.json)



#### Override `_static_init`

the BaseTrajectory._register() should be called in this function:

```gdscript
static func _register(type_name : String, _constructor : Callable, _validator : Callable = func(_p): return true):
```

parameter explaination:

- type_name
  - trajectory type used in the factory function, like "linear" and "circle"
- _constructor
  - Actually create the required trajectory type
- _validator
  - validate the passed parameter dict



Example(LinearTrajectory):

```gdscript
static func _static_init() -> void:
	var validator := func(_p : Dictionary): #define the validator, legal for true
		return (
			_p.has("speed") and _p.speed is float and
			_p.has("direction") and _p.direction is float and 
			((_p.has("acceleration") and _p.acceleration is float) or not _p.has("acceleration")) and
			((_p.has("ending_phase") and _p.ending_phase is float) or not _p.has("ending_phase"))
		)
	
	#注册函数
	BaseTrajectory._register(
		"linear", #type name
		func(_p) : #constructor
			return LinearTrajectory.new(
				_p.speed, #required parameter
				_p.direction,
				0 if not _p.has("acceleration") else _p.acceleration, #optional parameter
				-1 if not _p.has("ending_phase") else _p.ending_phase
			),
		validator #validator
	)
```



#### Add script path

Since the _static_init is called when we load or preload a script, the autoload script (Trajectory/trajectory_register.gd), will automatically load all the scripts in the register.json by the load() method



it should already has the following content (usually in **res://addons/easy_trajectory/UserConfig/register.json**):

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

For the sake of readability, please add your custom script in the "custom" section



### Reset and Redefine Support

#### Reset

the reset function:

```gdscript
#BaseTrajectory
_resetter : Callable
```

assign to the *_resetter* to enable reset, remember to **bind()** the original parameters when creating



Example (LinearTrajectory)

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

**Note**: you don't need to maintain the basic attributes such as _progress, _last_progress, _valid and _ended in the _resetter



#### Redefine

the redefine function:

```gdscript
#BaseTrajectory
_redefiner := func(_p): return
```

assign to the *_redefiner* to enable redefine, it will accept a dictionary, and extract necessary parameters from it

**Note**:

- Dictionary parameters **don't need** to be validated in *_redefiner*, it will be handled automatically
- remember to bind() the new parameters to *_resetter* in the *_redefiner*



Example (LinearTrajectory)

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



### For TrajectoryHolder

TrajectoryHolder has an additional attribute to handle the *ended* signal emitted by the sub trajectory

```gdscript
var _connector := func(item : BaseTrajectory):
	return
```



Example (SequenceTrajectoryHolder):

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

**Note**: Remember to call the *_init* method in the super class if directly or indirectly extended from TrajectoryHolder, or the signal handling may not function correctly.



TrajectoryHolder has a override version of *reset* and *redefine* method, so you don't need to handle *_resetter* and *_redefiner*, and if *_redefiner* is defined, there is no need to bind() the parameters to *_resetter*



In the override redefine(), the *_redefiner* will be called after the *ended* signal connected, and before the reset() method is called

------

Now we can use our custom trajectory type just like the build-in ones



## Some words

Upcoming features:
- parameter mutate (change but not reset the trajectory)
- Object pooling for bullet-hell scenarios

Thanks for using and support EasyTrajectory! ღ( ´･ᴗ･` )