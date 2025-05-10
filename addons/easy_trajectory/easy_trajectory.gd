@tool
extends EditorPlugin

const register_path : String = "res://addons/easy_trajectory/Trajectory/trajectory_register.gd"

func _enable_plugin() -> void:
	add_autoload_singleton("TrajectoryRegister",register_path)

func _disable_plugin() -> void:
	remove_autoload_singleton("TrajectoryRegister")

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	register_default_type()


func _exit_tree() -> void:
	remove_default_type()


func register_default_type():
	add_custom_type(
		"BaseTrajectory",
		"RefCounted",
		preload("res://addons/easy_trajectory/Trajectory/base_trajectory.gd"),
		preload("res://addons/easy_trajectory/Icons/TrajectoryIcon.png")
	)
	add_custom_type(
		"LinearTrajectory",
		"BaseTrajectory",
		preload("res://addons/easy_trajectory/Trajectory/SimpleTrajectory/linear.gd"),
		preload("res://addons/easy_trajectory/Icons/TrajectoryIcon.png")
	)
	add_custom_type(
		"CircleTrajectory",
		"BaseTrajectory",
		preload("res://addons/easy_trajectory/Trajectory/SimpleTrajectory/circle.gd"),
		preload("res://addons/easy_trajectory/Icons/TrajectoryIcon.png")
	)
	add_custom_type(
		"VelAccelTrajectory",
		"BaseTrajectory",
		preload("res://addons/easy_trajectory/Trajectory/ComplexTrajectory/va.gd"),
		preload("res://addons/easy_trajectory/Icons/TrajectoryIcon.png")
	)
	add_custom_type(
		"BezierTrajectory",
		"BaseTrajectory",
		preload("res://addons/easy_trajectory/Trajectory/ComplexTrajectory/bezier.gd"),
		preload("res://addons/easy_trajectory/Icons/TrajectoryIcon.png")
	)
	add_custom_type(
		"TrajectoryHolder",
		"BaseTrajectory",
		preload("res://addons/easy_trajectory/Trajectory/TrajectoryHolder/trajectory_holder.gd"),
		preload("res://addons/easy_trajectory/Icons/TrajectoryIcon.png")
	)
	add_custom_type(
		"BlendTrajectoryHolder",
		"TrajectoryHolder",
		preload("res://addons/easy_trajectory/Trajectory/TrajectoryHolder/blend_trajectory_holder.gd"),
		preload("res://addons/easy_trajectory/Icons/TrajectoryIcon.png")
	)
	add_custom_type(
		"SequenceTrajectoryHolder",
		"TrajectoryHolder",
		preload("res://addons/easy_trajectory/Trajectory/TrajectoryHolder/sequence_trajectory_holder.gd"),
		preload("res://addons/easy_trajectory/Icons/TrajectoryIcon.png")
	)

func remove_default_type():
	remove_custom_type("BaseTrajectory")
	remove_custom_type("LinearTrajectory")
	remove_custom_type("CircleTrajectory")
	remove_custom_type("VelAccelTrajectory")
	remove_custom_type("BezierTrajectory")
	remove_custom_type("TrajectoryHolder")
	remove_custom_type("BlendTrajectoryHolder")
	remove_custom_type("SequenceTrajectoryHolder")
