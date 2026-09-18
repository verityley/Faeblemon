extends UIElement

@export var actors:Dictionary[Elements,Node3D]
@export var firstSlot:bool = false
@export var selected:bool
var textOut:String = "Summoned"
var textKO:String = "Dispelled"

enum Elements {
	sprite=0,
	blocker,
	button,
	bookmark
}

func SetupSlot(entry:Faeble):
	actors[Elements.sprite].texture = entry.sprite
	if firstSlot:
		actors[Elements.blocker].show()
		actors[Elements.blocker].get_child(0).text = textOut
		actors[Elements.button].hide()
	if entry.fainted:
		actors[Elements.blocker].show()
		actors[Elements.blocker].get_child(0).text = textKO
		actors[Elements.button].hide()
		pass #Show blocker, hide area3d, set text
	else:
		actors[Elements.blocker].hide()
		actors[Elements.blocker].get_child(0).text = ""
		actors[Elements.button].show()
	rotation_degrees = Vector3(0,0,0)
	actors[Elements.bookmark].hide()
	actors[Elements.bookmark].SetupBookmark(entry)

func DisplaySlot(revert:bool=false) -> bool:
	var tween = get_tree().create_tween()
	if revert:
			tween.tween_property(self, "rotation_degrees", Vector3(0,0,0), 0.5)
			await tween.finished
			actors[Elements.bookmark].hide()
			selected = false
			pass #turn back around to frontface
			return false
	if selected:
		await ShiftHide()
		selected = false
		pass #shift hide and return true
		return true
	else:
		actors[Elements.bookmark].show()
		tween.tween_property(self, "rotation_degrees", Vector3(0,180,0), 0.5)
		await tween.finished
		selected = true
		pass #turn to show bookmark
		return false
