@tool
extends EditorPlugin


func _enter_tree():
	Log.prn("<Cam>")
	add_autoload_singleton("Cam", "res://addons/camera/Camera.gd")


func _exit_tree():
	remove_autoload_singleton("Cam")
	Log.prn("</Cam>")
