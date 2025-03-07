extends Node3D

@onready var speech_bubble: MeshInstance3D = $NewMessageAnchor/BubbleAnchor/SpeechBubble


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(3.0).timeout
	await Typewriter("Hello World!", 1.0, speech_bubble.get_child(0))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func InitializeMessages():
	pass #Set up message anchors and ensure arrays are clear and primed

func NewMessage():
	pass #Create new bubble, assign to anchor, scroll messages

func Typewriter(toPrint:String, typeSpeed:float, textField):
	var printText:String = ""
	var typeTime:float = typeSpeed / toPrint.length()
	
	for letter in toPrint:
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
