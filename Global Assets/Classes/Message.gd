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

#@export_category("Textbox FX")
#@export var fxShake:bool
#@export var fxBounce:bool
#@export var fxTilt:bool
#@export var fxGrow:bool
#@export var fxShrink:bool

@export_category("Choice Parameters")
@export var choice:bool #Whether or not message has attached choices
@export var choiceTemplate:Dictionary = {
	"ChoiceID" = 1,
	"ChoiceLabel" = "Text to Display",
	"Message" = "Replace with Message Resource",
	"Conversation" = "Replace with Convo Resource"
}
@export var choiceOutcomes:Dictionary
#Selecting a choice skips to a matching message within the selected conversation

@export_category("Rumor Parameters")
@export var rumor:bool #Whether or not message is a possible rumor
@export var rumorTags:Dictionary
@export var insight:bool
