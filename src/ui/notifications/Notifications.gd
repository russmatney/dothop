@tool
extends VBoxContainer

var scene_ready: bool

@export var add_notif: String = "" :
	set(txt):
		add_notif = txt
		if txt and scene_ready:
			_on_notification({"msg": txt})

@export var add_rich_notif: String = "" :
	set(txt):
		add_rich_notif = txt
		if txt and scene_ready:
			_on_notification({"msg": txt, "rich": true})

@warning_ignore("unused_private_class_variable")
@export var _clear : bool :
	set(v):
		for ch: Node in get_children():
			ch.queue_free()

@export var side: String = "left"

#############################################################

func _ready() -> void:
	DotHop.notification.connect(_on_notification)
	DotHop.notif("[Notifications online]", {id="initial"})
	scene_ready = true

#############################################################

var notif_label: PackedScene = preload("res://src/ui/notifications/NotifLabel.tscn")
var notif_rich_label: PackedScene = preload("res://src/ui/notifications/NotifRichLabel.tscn")

var id_notifs: Dictionary = {}

# TODO support passed icon to decorate the notif/toast
func _on_notification(notif: Dictionary) -> void:
	var lbl: Variant # aka my Label + RichTextLabel disaster

	var text: String = notif.get("text", notif.get("msg"))

	var id: String = notif.get("id", text)
	var found_existing: bool = false
	if id != null:
		if id in id_notifs:
			var l: Variant = id_notifs[id]
			if is_instance_valid(l) and l is Node and not (l as Node).is_queued_for_deletion():
				lbl = l as Node
				found_existing = true
			else:
				id_notifs.erase(id)

	if not found_existing and notif.get("rich"):
		lbl = notif_rich_label.instantiate()
		# two ticking time bombs
		(lbl as RichTextLabel).text = "[%s]%s[/%s]" % [side, text, side]
	elif not found_existing:
		lbl = notif_label.instantiate()
		# await a weary traveler
		(lbl as Label).text = text

	if notif.get("rich"):
		lbl.text = "[%s]%s[/%s]" % [side, text, side]
	else:
		lbl.text = text
	lbl.ttl = notif.get("ttl", 3.0)

	if found_existing:
		@warning_ignore("unsafe_method_access")
		lbl.reset_ttl()
		@warning_ignore("unsafe_method_access")
		lbl.reemphasize()

	if id != null:
		id_notifs[id] = lbl

	if not found_existing:
		add_child(lbl as Node)
	# if Engine.is_editor_hint():
	# 	lbl.set_owner(owner)
