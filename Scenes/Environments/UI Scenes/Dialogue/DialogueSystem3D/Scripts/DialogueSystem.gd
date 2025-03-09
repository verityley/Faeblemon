extends Node3D

@export var scrollTime:float
@export var typingTime:float

@export var anchors:Array[Node3D]
var anchorPositions:Array[Vector3]
var anchorRotations:Array[Vector3]
var anchorScales:Array[Vector3]

@export var speechBubbles:Array[Node3D]

@export var conversation:Array[Message]
var messageLog:Array[Message]
@onready var logSize:int
var logIndex:int

func _ready():
	InitializeAnchors()
	await get_tree().create_timer(2.0).timeout
	await NewMessage(conversation[0])
	await NewMessage(conversation[1])
	await NewMessage(conversation[2])
	await NewMessage(conversation[3])
	await NewMessage(conversation[4])
	await ScrollDown()
	await ScrollDown()
	await ScrollDown()
	await ScrollDown()
	await ScrollDown()
	await ScrollUp()
	await ScrollUp()
	await ScrollUp()
	await ScrollUp()
	await ScrollUp()
	await ScrollUp()





func InitializeAnchors():
	var i:int = 0
	logIndex = 0
	logSize = messageLog.size()
	for anchor in anchors:
		anchorPositions.append(anchor.global_position)
		anchorRotations.append(anchor.global_rotation)
		anchorScales.append(anchor.scale)
		speechBubbles[i].global_position = anchor.global_position
		speechBubbles[i].rotation = anchor.global_rotation
		speechBubbles[i].scale = anchor.scale
		speechBubbles[i].show()
		SetMessage(i, logSize-i)
		if i == 0 or i == 5:
			speechBubbles[i].hide()
		i+=1

func ScrollDown():
	if (logIndex-1) < 1:
		print("Message log has reached first message in conversation")
		return #Message log has reached first message in conversation, cannot scroll further
	speechBubbles[5].show()
	SetMessage(5, logIndex-5)
	var firstBubble = speechBubbles.pop_front()
	speechBubbles.append(firstBubble)
	BubbleReposition()
	await get_tree().create_timer(scrollTime+0.01).timeout
	speechBubbles[0].hide()
	if (logIndex-1) > 0:
		logIndex -= 1

func ScrollUp():
	if (logIndex+1) > logSize-1:
		print("Message log is up to date")
		return
		pass #Message log is up to date, cannot scroll further
	speechBubbles[0].show()
	SetMessage(0, logIndex+1)
	var lastBubble = speechBubbles.pop_back()
	speechBubbles.push_front(lastBubble)
	BubbleReposition()
	await get_tree().create_timer(scrollTime+0.01).timeout
	speechBubbles[5].hide()
	logIndex += 1

func NewMessage(newMessage:Message):
	speechBubbles[0].get_child(0).text = ""
	speechBubbles[0].show()
	var lastBubble = speechBubbles.pop_back()
	speechBubbles.push_front(lastBubble)
	BubbleReposition()
	await get_tree().create_timer(scrollTime+0.01).timeout
	speechBubbles[5].hide()
	await Typewriter(speechBubbles[1], newMessage)
	messageLog.append(newMessage)
	logSize += 1
	logIndex += 1

func BubbleReposition():
	var newOrder:Array[Node3D]
	var i:int = 0
	for bubble in speechBubbles:
		var posiTween = get_tree().create_tween()
		var rotaTween = get_tree().create_tween()
		var scaleTween = get_tree().create_tween()
		posiTween.tween_property(bubble, "global_position", anchorPositions[i], scrollTime)
		rotaTween.tween_property(bubble, "global_rotation", anchorRotations[i], scrollTime)
		scaleTween.tween_property(bubble, "scale", anchorScales[i], scrollTime)
		newOrder.append(bubble)
		i+=1
	speechBubbles = newOrder.duplicate()

func SetMessage(bubbleIndex:int, logIndex:int):
	prints("Speech Bubble:",bubbleIndex, "Message Log Index:", logIndex)
	if logIndex > logSize-1 or logIndex < 0:
		speechBubbles[bubbleIndex].hide()
		print("This speech bubble has no message, hiding object!")
	else:
		speechBubbles[bubbleIndex].get_child(0).text = messageLog[logIndex].messageText
		speechBubbles[bubbleIndex].show()
	

func Typewriter(target:Node3D, toPrint:Message):
	var printText:String = ""
	var textField:Label3D = target.get_child(0)
	var typeTime:float = typingTime / toPrint.messageText.length()
	
	for letter in toPrint.messageText:
		printText += letter
		#print(printText)
		textField.text = printText
		await get_tree().create_timer(typeTime).timeout
	pass #Write character by character, playing designated sound for each if imported

func ScrollMessages():
	
	pass #Positive or negative moves message array order, and tweens messages between anchors, then reparent

func DeleteMessage():
	pass #Hide or delete bubble.

func ClearMessages():
	pass #Clear out message anchors and arrays

func PresentChoice():
	pass #If the message has a value for choices, then import from there. Otherwise present default y/n
