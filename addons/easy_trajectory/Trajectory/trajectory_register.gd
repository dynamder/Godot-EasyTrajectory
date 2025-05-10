extends Node

var _registered : PackedStringArray

const register_config_path = "res://addons/easy_trajectory/UserConfig/register.json"

func _ready() -> void:
	var json = JSON.new()
	var file = FileAccess.open(register_config_path,FileAccess.READ)
	var content : String = file.get_as_text()
	
	var reg = json.parse_string(content)
	for mk in reg:
		for item in reg[mk]:
			if item is String:
				load(item)
			else:
				push_error("EasyTrajectory: invalid register script path in %s" % mk)
