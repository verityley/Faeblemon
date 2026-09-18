extends Resource
class_name Message

@export var messageID:String

@export_category("Message Parameters")
@export_multiline var messageText:String
@export var messageSpeaker:Speaker
@export var messageSpeed:float #Delay between each letter
@export var messageMute:bool #Message ignores the Speaker sound fx
@export var messageInstant:bool #Message ignores the per-letter text delay
#@export var messageRecord:bool = true #Message is recorded to dialogue history/notebook
@export var messageSkip:bool #This tells the conversation ordering to skip over this message
#Message skip is used when a message has been seen once before, such as in a looping choice branch

#@export_category("Textbox FX")
#@export var fxShake:bool
#@export var fxBounce:bool
#@export var fxTilt:bool
#@export var fxGrow:bool
#@export var fxShrink:bool

@export_category("Conversation Parameters")
@export var targetMessage:Message #If empty, end conversation
@export var hasChoices:bool = false
@export var choiceTargets:Array[Message]
@export var choiceText:Array[String]

@export var switchLabel:String #If has label, dialogue system does a switch database lookup
@export var switchValue:bool
@export var tallyLabel:String
@export var tallyValue:int
