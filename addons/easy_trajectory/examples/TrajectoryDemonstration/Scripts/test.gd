extends Node2D
@onready var initial_pos_marker_2d: Marker2D = $InitialPosMarker2D
@onready var move_object: Sprite2D = $MoveObject
@onready var line_2d: Line2D = $Line2D
@onready var end_label: Label = $CanvasLayer/HBoxContainer/VBoxContainer/Control2/EndLabel




@onready var linear_button: Button = %LinearButton
@onready var circle_button: Button = $CanvasLayer/HBoxContainer/VBoxContainer/ScrollContainer/VBoxContainer/Circle/CircleButton
@onready var va_button: Button = $CanvasLayer/HBoxContainer/VBoxContainer/ScrollContainer/VBoxContainer/VelAccel/VelAccelButton
@onready var bezier_button: Button = $CanvasLayer/HBoxContainer/VBoxContainer/ScrollContainer/VBoxContainer/Bezier/BezierButton


var stop : bool = true

var traj : BaseTrajectory

func connector():
	end_label.show()
	stop = true

func _physics_process(delta: float) -> void:
	if not stop:
		traj.update(delta)
		move_object.position += traj.evaluate(delta)
		line_2d.add_point(move_object.position)

func _on_reset_button_pressed() -> void:
	move_object.position = initial_pos_marker_2d.position
	stop = true
	end_label.hide()
	line_2d.clear_points()


func _on_linear_button_pressed() -> void:
	
	#使用参数字典构建器
	var linear_traj_dict := LinearTrajDict.new().set_speed_accel(
		float(linear_button.speed.get_line_edit().text),
		float(linear_button.acceleration.get_line_edit().text)
	).set_direction(
		float(linear_button.direction.get_line_edit().text)
	).set_ending_phase(
		float(linear_button.ending_phase.get_line_edit().text)
	).build()
	
	traj = BaseTrajectory.create(
		"linear",
		#直接初始化字典方式
		#{
			#"speed" : float(linear_button.speed.get_line_edit().text),
			#"direction" : float(linear_button.direction.get_line_edit().text),
			#"acceleration" : float(linear_button.acceleration.get_line_edit().text),
			#"ending_phase" : float(linear_button.ending_phase.get_line_edit().text)
		#}
		linear_traj_dict
	)
	traj.ended.connect(connector)
	end_label.hide()
	stop = false


func _on_circle_button_pressed() -> void:
	
	#使用参数字典构建器
	var circle_traj_dict := CircleTrajDict.new().set_radius(
		float(circle_button.radius.get_line_edit().text)
	).set_angle(
		float(circle_button.angle.get_line_edit().text)
	).set_ang_speed_accel(
		float(circle_button.angular_speed.get_line_edit().text),
		float(circle_button.angular_acceleration.get_line_edit().text)
	).set_ending_phase(
		float(circle_button.ending_phase.get_line_edit().text)
	).build()
	
	traj = BaseTrajectory.create(
		"circle",
		#直接初始化字典方式
		#{
			#"radius": float(circle_button.radius.get_line_edit().text),
			#"angle": float(circle_button.angle.get_line_edit().text),
			#"angular_speed" : float(circle_button.angular_speed.get_line_edit().text),
			#"angular_acceleration" : float(circle_button.angular_acceleration.get_line_edit().text),
			#"ending_phase" : float(circle_button.ending_phase.get_line_edit().text)
		#}
		circle_traj_dict
	)
	traj.ended.connect(connector)
	end_label.hide()
	stop = false


func _on_vel_accel_button_pressed() -> void:
	
	#使用参数字典构建器
	var va_traj_dict := VaTrajDict.new().set_vel(
		Vector2(
			float(va_button.vx.get_line_edit().text),
			float(va_button.vy.get_line_edit().text)
		)
	).set_accel(
		Vector2(
			float(va_button.ax.get_line_edit().text),
			float(va_button.ay.get_line_edit().text)
		)
	).set_ending_phase(
		float(va_button.ending_phase.get_line_edit().text)
	).build()
	
	traj = BaseTrajectory.create(
		"velaccel",
		#直接初始化字典方式
		#{
			#"velocity": Vector2(
				#float(va_button.vx.get_line_edit().text),
				#float(va_button.vy.get_line_edit().text)
			#),
			#"acceleration": Vector2(
				#float(va_button.ax.get_line_edit().text),
				#float(va_button.ay.get_line_edit().text)
			#),
			#"ending_phase": float(va_button.ending_phase.get_line_edit().text)
		#}
		va_traj_dict
	)
	traj.ended.connect(connector)
	end_label.hide()
	stop = false


func _on_bezier_button_pressed() -> void:
	move_object.position.y += 170
	
	#使用参数字典构建器
	var bezier_dict := BezierTrajDict.new().set_points(
		[
			{
				"point": Vector2(
					float(bezier_button.pos1x.get_line_edit().text),
					float(bezier_button.pos1y.get_line_edit().text)
				),
				"out": Vector2(
					float(bezier_button.out1x.get_line_edit().text),
					float(bezier_button.out1y.get_line_edit().text)
				)
			},
			{
				"point": Vector2(
					float(bezier_button.pos2x.get_line_edit().text),
					float(bezier_button.pos2y.get_line_edit().text)
				),
				"in": Vector2(
					float(bezier_button.in2x.get_line_edit().text),
					float(bezier_button.in2y.get_line_edit().text)
				),
				"out": Vector2(
					float(bezier_button.out2x.get_line_edit().text),
					float(bezier_button.out2y.get_line_edit().text)
				)
			},
			{
				"point": Vector2(
					float(bezier_button.pos3x.get_line_edit().text),
					float(bezier_button.pos3y.get_line_edit().text)
				),
				"in": Vector2(
					float(bezier_button.in3x.get_line_edit().text),
					float(bezier_button.in3y.get_line_edit().text)
				)
			}
		]
	).set_speed_accel(
		float(bezier_button.speed.get_line_edit().text),
		float(bezier_button.acceleration.get_line_edit().text)
	).build()
	
	traj = BaseTrajectory.create(
		"bezier",
		#直接初始化字典方式
		#{
			#"speed": float(bezier_button.speed.get_line_edit().text),
			#"acceleration" : float(bezier_button.acceleration.get_line_edit().text),
			#"points": [
				#{
					#"point": Vector2(
						#float(bezier_button.pos1x.get_line_edit().text),
						#float(bezier_button.pos1y.get_line_edit().text)
					#),
					#"out": Vector2(
						#float(bezier_button.out1x.get_line_edit().text),
						#float(bezier_button.out1y.get_line_edit().text)
					#)
				#},
				#{
					#"point": Vector2(
						#float(bezier_button.pos2x.get_line_edit().text),
						#float(bezier_button.pos2y.get_line_edit().text)
					#),
					#"in": Vector2(
						#float(bezier_button.in2x.get_line_edit().text),
						#float(bezier_button.in2y.get_line_edit().text)
					#),
					#"out": Vector2(
						#float(bezier_button.out2x.get_line_edit().text),
						#float(bezier_button.out2y.get_line_edit().text)
					#)
				#},
				#{
					#"point": Vector2(
						#float(bezier_button.pos3x.get_line_edit().text),
						#float(bezier_button.pos3y.get_line_edit().text)
					#),
					#"in": Vector2(
						#float(bezier_button.in3x.get_line_edit().text),
						#float(bezier_button.in3y.get_line_edit().text)
					#)
				#}
			#]
		#}
		bezier_dict
	)
	traj.ended.connect(connector)
	end_label.hide()
	stop = false


func _on_sequence_button_pressed() -> void:
	traj = BaseTrajectory.create(
		"sequence_holder",
		{
			1 : {
				"type" : "linear",
				"param" : {
					"speed" : 100.0,
					"direction" : -40.0,
					"ending_phase" : 150.0
				}
			},
			2 : {
				"type" : "circle",
				"param" : {
					"radius" : 100.0,
					"angular_speed" : 180.0,
					"ending_phase" : 270.0
				}
			}
		}
	)
	traj.ended.connect(connector)
	end_label.hide()
	stop = false


func _on_blender_button_pressed() -> void:
	move_object.position -= Vector2(200,200)
	traj = BaseTrajectory.create(
		"blend_holder",
		{
			1 : {
				"type": "linear",
				"param": {
					"speed" : 100.0,
					"direction" : 30.0,
					"ending_phase" : 650.0
				}
			},
			2 : {
				"type": "circle",
				"param": {
					"radius" : 95.0,
					"angular_speed" : 90.0,
					"ending_phase": 585.0
				}
			}
		}
		
	)
	traj.ended.connect(connector)
	end_label.hide()
	stop = false
