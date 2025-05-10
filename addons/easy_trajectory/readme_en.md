# EasyTrajectory

EasyTrajectory is a **2D scene** plugin for quickly and easily creating trajectories like bullet paths and enemy movements. Written entirely in GDScript, it allows flexible creation of complex trajectories through combination of different trajectory types.

------

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
Bezier curve trajectory:
```gdscript
_curve : Curve2D # Bezier curve (auto-generated)
speed : float # Speed
acceleration : float # Acceleration (optional, default 0)
```

Factory example (requires `points` array):
```gdscript
BaseTrajectory.create(
    "bezier",
    {
        "points" : [
            Vector2(0,0),
            Vector2(30,40),
            Vector2(-10,20),
            Vector2(-60,80)
        ],
        "speed" : 30.0
    }
)
```



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



Now we can use our custom trajectory type just like the build-in ones



## Some words

Upcoming features:
- Trajectory resetting/redefining
- Object pooling for bullet-hell scenarios

Thanks for using and support EasyTrajectory! ღ( ´･ᴗ･` )