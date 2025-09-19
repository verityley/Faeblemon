extends Node3D
class_name GossipSystem

signal finished

@export var scrollTime:float

@export var anchors:Array[Node3D]
var anchorPositions:Array[Vector3]
var anchorRotations:Array[Vector3]
var anchorScales:Array[Vector3]

@export var speechBubble:Node3D
var currentlyTyping:Message



func _ready():
	InitializeAnchors()

func InitializeAnchors():
	for anchor in anchors:
		anchorPositions.append(anchor.position)
		anchorRotations.append(anchor.rotation)
		anchorScales.append(anchor.scale)
	speechBubble.position = anchors[0].position
	speechBubble.rotation = anchors[0].rotation
	speechBubble.scale = anchors[0].scale
	speechBubble.hide()

func NewMessage(newMessage:Message):
	emit_signal("finished")
	speechBubble.get_child(0).text = ""
	await BubbleDisplay(true)
	currentlyTyping = newMessage
	QuickMessage(newMessage)
	currentlyTyping = null
	#await get_tree().create_timer(time).timeout
	#await BubbleDisplay(false)

func BubbleDisplay(show:bool):
	var posiTween = get_tree().create_tween()
	var rotaTween = get_tree().create_tween()
	var scaleTween = get_tree().create_tween()
	var i:int = -1
	if show:
		i=1
		speechBubble.show()
	else:
		i=0
	posiTween.tween_property(speechBubble, "position", anchorPositions[i], scrollTime)
	rotaTween.tween_property(speechBubble, "rotation", anchorRotations[i], scrollTime)
	scaleTween.tween_property(speechBubble, "scale", anchorScales[i], scrollTime)
	await get_tree().create_timer(scrollTime+0.01).timeout
	if !show:
		speechBubble.hide()

func QuickMessage(toPrint:Message):
	currentlyTyping = toPrint.duplicate()
	var textField:Label3D = speechBubble.get_child(0)
	textField.text = toPrint.messageText

func ClearMessage():
	speechBubble.get_child(0).text = ""
	BubbleDisplay(false)
	currentlyTyping = null
