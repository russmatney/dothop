@tool
extends EditorPlugin

var editor_interface

func _enter_tree():
	Log.pr("<DJ>")
	add_autoload_singleton("DJ", "res://addons/dj/DJ.gd")

func _exit_tree():
	remove_autoload_singleton("DJ")
	Log.prn("</DJ>")
