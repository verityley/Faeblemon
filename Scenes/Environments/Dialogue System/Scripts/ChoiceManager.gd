extends Node3D

@export var dialogueSystem:Node3D

var selectedChoice:int
var pickedChoice:int
var choicesShown:bool

@export var anchors:Array[Node3D]
var anchorPositions:Array[Vector3]
var anchorRotations:Array[Vector3]
#var anchorScales:Array[Vector3]

var tempPositions:Array[Vector3]
var tempRotations:Array[Vector3]

@export var speechBubbles:Array[Node3D]
@export var bubblesGroup:Node3D
@export var scrollTime:float

@export var currentMessage:Message


func _ready():
	InitializeAnchors()
	#await get_tree().create_timer(2.0).timeout
	ClearChoices()
	#await get_tree().create_timer(3.0).timeout
	#PresentChoices(testMessage.choiceText.size(),testMessage)
	#ScrollUp()
	pass


func _input(event):
	if pickedChoice != -1 and choicesShown:
		if event.is_action_pressed("LeftMouse"):
			print("Selecting!")
			SelectChoice(currentMessage.choiceText.size(), pickedChoice)


func InitializeAnchors():
	var i:int = 0
	for anchor in anchors:
		anchorPositions.append(anchor.global_position)
		anchorRotations.append(anchor.global_rotation)
		#anchorScales.append(anchor.scale)
		speechBubbles[i].global_position = anchor.global_position
		speechBubbles[i].rotation = anchor.global_rotation
		#speechBubbles[i].scale = anchor.scale
		if i > 0:
			speechBubbles[i].show()
		i+=1
	for temp in anchorPositions:
		tempPositions.append(anchorPositions[0])
		tempRotations.append(anchorRotations[0])


func PresentChoices(choiceCount:int, message:Message):
	currentMessage = message
	match choiceCount:
		2:
			speechBubbles[2].show()
			speechBubbles[3].show()
			tempPositions[2] = anchorPositions[2]
			tempPositions[3] = anchorPositions[3]
			tempRotations[2] = anchorRotations[2]
			tempRotations[3] = anchorRotations[3]
			SetMessage(2,message.choiceText[1])
			SetMessage(3,message.choiceText[0])
		3:
			speechBubbles[2].show()
			speechBubbles[3].show()
			speechBubbles[4].show()
			tempPositions[2] = anchorPositions[2]
			tempPositions[3] = anchorPositions[3]
			tempPositions[4] = anchorPositions[4]
			tempRotations[2] = anchorRotations[2]
			tempRotations[3] = anchorRotations[3]
			tempRotations[4] = anchorRotations[4]
			SetMessage(2,message.choiceText[2])
			SetMessage(3,message.choiceText[1])
			SetMessage(4,message.choiceText[0])
		4:
			speechBubbles[1].show()
			speechBubbles[2].show()
			speechBubbles[3].show()
			speechBubbles[4].show()
			tempPositions[1] = anchorPositions[1]
			tempPositions[2] = anchorPositions[2]
			tempPositions[3] = anchorPositions[3]
			tempPositions[4] = anchorPositions[4]
			tempRotations[1] = anchorRotations[1]
			tempRotations[2] = anchorRotations[2]
			tempRotations[3] = anchorRotations[3]
			tempRotations[4] = anchorRotations[4]
			SetMessage(1,message.choiceText[3])
			SetMessage(2,message.choiceText[2])
			SetMessage(3,message.choiceText[1])
			SetMessage(4,message.choiceText[0])
	BubbleReposition()
	choicesShown = true


func TargetChoice(selected:bool, bubble:int=-1):
	#print("Signal")
	var target:int = speechBubbles.find(bubblesGroup.get_child(bubble))
	var scaleTween = get_tree().create_tween()
	var scaleTween2 = get_tree().create_tween()
	if selected == false:
		if pickedChoice != -1:
			scaleTween.tween_property(speechBubbles[pickedChoice], "scale", Vector3(1,1,1), scrollTime)
		pickedChoice = -1
		#print("No Choice")
		return
	if pickedChoice != -1:
		scaleTween.tween_property(speechBubbles[pickedChoice], "scale", Vector3(1,1,1), scrollTime)
	scaleTween2.tween_property(speechBubbles[target], "scale", Vector3(1.1,1.1,1.1), scrollTime)
	pickedChoice = target


func SelectChoice(choiceCount:int, choice:int):
	match choiceCount:
		2:
			if choice == 2:
				selectedChoice = 1
			elif choice == 3:
				selectedChoice = 0
		3:
			if choice == 2:
				selectedChoice = 2
			elif choice == 3:
				selectedChoice = 1
			elif choice == 4:
				selectedChoice = 0
		4:
			if choice == 1:
				selectedChoice = 3
			elif choice == 2:
				selectedChoice = 2
			elif choice == 3:
				selectedChoice = 1
			elif choice == 4:
				selectedChoice = 0
	if dialogueSystem.choosing == true:
		dialogueSystem.ProgressChoices(selectedChoice)
		ClearChoices()


func SetMessage(bubbleIndex:int, text:String):
	speechBubbles[bubbleIndex].get_child(0).text = text
	speechBubbles[bubbleIndex].show()


func BubbleReposition():
	var newOrder:Array[Node3D]
	var i:int = 0
	for bubble in speechBubbles:
		var posiTween = get_tree().create_tween()
		var rotaTween = get_tree().create_tween()
		var scaleTween = get_tree().create_tween()
		posiTween.tween_property(bubble, "global_position", tempPositions[i], scrollTime)
		rotaTween.tween_property(bubble, "global_rotation", tempRotations[i], scrollTime)
		#scaleTween.tween_property(bubble, "scale", anchorScales[i], scrollTime)
		newOrder.append(bubble)
		i+=1
	speechBubbles = newOrder.duplicate()


func ClearChoices():
	choicesShown = false
	var i:int = 0
	pickedChoice = -1
	selectedChoice = -1
	for temp in anchorPositions:
		tempPositions[i] = anchorPositions[0]
		tempRotations[i] = anchorRotations[0]
		i += 1
	BubbleReposition()
	await get_tree().create_timer(scrollTime-0.05).timeout
	for bubble in speechBubbles:
		bubble.scale = Vector3(1,1,1)
		bubble.hide()
