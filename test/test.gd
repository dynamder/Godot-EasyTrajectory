extends Node2D

var traj : BaseTrajectory
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var path_2d: Path2D = $Path2D
@onready var line_2d: Line2D = $Line2D

func _ready() -> void:
	
	
	traj = BaseTrajectory.create(
		"sequence_holder",
		{
			1 : {
				"type" : "linear",
				"param" : {
					"speed" : 50.0,
					"direction" : 60.0,
					"ending_phase" : 200.0
				}
			},
			2 : {
				"type" : "linear",
				"param" : {
					"speed" : 50.0,
					"direction" : 20.0,
					"ending_phase" : 200.0
				}
			}
		}
	)
	traj.ended.connect(
		func():
			traj.redefine(
				{
					1 : {
						"type" : "linear",
						"param" : {
							"speed" : 50.0,
							"direction" : 0.0,
							"ending_phase" : 200.0
						}
					},
					2 : {
						"type" : "linear",
						"param" : {
							"speed" : 50.0,
							"direction" : 90.0,
							"ending_phase" : 200.0
						}
					}
				}
			)
	)
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
							"direction" : 30.0,
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
	
	BaseTrajectory.create(
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

func _process(delta: float) -> void:
	traj.update(delta)
	sprite_2d.position += traj.evaluate(delta)
