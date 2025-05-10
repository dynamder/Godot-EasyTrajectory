extends Node2D

var traj : BaseTrajectory
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	traj = BaseTrajectory.create(
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
		

func _process(delta: float) -> void:
	traj.update(delta)
	sprite_2d.position += traj.evaluate(delta)
