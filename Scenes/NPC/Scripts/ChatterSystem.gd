extends Node3D
class_name ChatterSystem

var eventTrigger:Event
signal finished

@export var scrollTime:float
@export var typingTime:float

@export var anchors:Array[Node3D]
var anchorPositions:Array[Vector3]
var anchorRotations:Array[Vector3]
var anchorScales:Array[Vector3]

@export var speechBubbles:Array[Node3D]

var messageLog:Array[Message]
var logSize:int
var logIndex:int
var currentlyTyping:Message

var scrolling:bool = false
var typing:bool = false
var talking:bool = false

func _ready():
	InitializeAnchors()

func _input(event: InputEvent):
	if !talking:
		return
	if event.is_action_pressed("Confirm") and typing:
		print("Skipping!")
		QuickMessage(currentlyTyping)
	if event.is_action_pressed("Confirm") and !scrolling and !typing:
		ProgressConversation()
	if event.is_action("ScrollUp") and !scrolling and !typing:
		ScrollUp()
	if event.is_action("ScrollDown") and !scrolling and !typing:
		ScrollDown()

func InitializeAnchors():
	var i:int = 0
	logIndex = 0
	logSize = messageLog.size()
	for anchor in anchors:
		anchorPositions.append(anchor.position)
		anchorRotations.append(anchor.rotation)
		anchorScales.append(anchor.scale)
		speechBubbles[i].position = anchor.position
		speechBubbles[i].rotation = anchor.rotation
		speechBubbles[i].scale = anchor.scale
		speechBubbles[i].show()
		SetMessage(i, logSize-i)
		if i == 0 or i == 3:
			speechBubbles[i].hide()
		i+=1

func ProgressConversation():
	while logIndex < logSize:
		await ScrollUp()
	var currentMessage:Message = messageLog.back()
	if currentMessage.targetMessage == null and !currentMessage.hasChoices:
		print("End of Conversation.")
		talking = false
		ClearMessages()
		emit_signal("finished")
		#Insert proper EndConvo signal here, TEMP
		#get_parent_node_3d().EndInteract() #TEMP
		return #Replace with EoC handling and event flow transferral
	var nextMessage:Message
	nextMessage = currentMessage.targetMessage
	NewMessage(nextMessage)

func ScrollDown():
	scrolling = true
	if (logIndex-1) < 1:
		print("Message log has reached first message in conversation")
		scrolling = false
		return #Message log has reached first message in conversation, cannot scroll further
	speechBubbles[3].show()
	SetMessage(3, logIndex-3)
	var firstBubble = speechBubbles.pop_front()
	speechBubbles.append(firstBubble)
	BubbleReposition()
	await get_tree().create_timer(scrollTime+0.01).timeout
	speechBubbles[0].hide()
	logIndex -= 1
	scrolling = false

func ScrollUp():
	scrolling = true
	if (logIndex+1) > logSize:
		print("Message log is up to date")
		scrolling = false
		return
		pass #Message log is up to date, cannot scroll further
	speechBubbles[0].show()
	SetMessage(0, logIndex)
	var lastBubble = speechBubbles.pop_back()
	speechBubbles.push_front(lastBubble)
	BubbleReposition()
	await get_tree().create_timer(scrollTime+0.01).timeout
	speechBubbles[3].hide()
	logIndex += 1
	scrolling = false

func NewMessage(newMessage:Message):
	scrolling = true
	speechBubbles[0].get_child(0).text = ""
	speechBubbles[0].show()
	var lastBubble = speechBubbles.pop_back()
	speechBubbles.push_front(lastBubble)
	BubbleReposition()
	await get_tree().create_timer(scrollTime+0.01).timeout
	speechBubbles[3].hide()
	currentlyTyping = newMessage
	if newMessage.messageInstant:
		QuickMessage(newMessage)
	else:
		await Typewriter(speechBubbles[1], newMessage)
	currentlyTyping = null
	messageLog.append(newMessage)
	logSize += 1
	logIndex += 1
	scrolling = false

func BubbleReposition():
	var newOrder:Array[Node3D]
	var i:int = 0
	for bubble in speechBubbles:
		var posiTween = get_tree().create_tween()
		var rotaTween = get_tree().create_tween()
		var scaleTween = get_tree().create_tween()
		posiTween.tween_property(bubble, "position", anchorPositions[i], scrollTime)
		rotaTween.tween_property(bubble, "rotation", anchorRotations[i], scrollTime)
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
	typing = true
	var printText:String = ""
	var textField:Label3D = target.get_child(0)
	var typeTime:float = typingTime / toPrint.messageText.length()
	for letter in toPrint.messageText:
		if typing == false:
			break
		printText += letter
		#print(printText)
		textField.text = printText
		await get_tree().create_timer(typeTime).timeout
	typing = false
	pass #Write character by character, playing designated sound for each if imported

func QuickMessage(toPrint:Message):
	typing = false
	print("Skipping Typewriter Effect")
	currentlyTyping = toPrint.duplicate()
	var textField:Label3D = speechBubbles[1].get_child(0)
	textField.text = toPrint.messageText

func ClearMessages():
	messageLog.clear()
	logIndex = 0
	logSize = messageLog.size()
	var i:int = 0
	for anchor in anchors:
		SetMessage(i, logSize-i)
		speechBubbles[i].hide()
		i+=1
	pass #Clear out message anchors and arrays
