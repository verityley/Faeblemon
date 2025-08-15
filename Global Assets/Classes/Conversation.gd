extends Resource
class_name Conversation

@export var messageFlow:Array[Dictionary]
@export var flowTemplate:Dictionary = { #Message Flow Template
	"Label" = "1A",
	"Message" = null, #preload("res://Database/Dialogue/Conversations/Messages/HelloWorld.tres"),
	"GoToLabel" = "Replace with target message label",
	"HasBranch" = false,
	"Branch" = ["2A","2B","2C"]
}
@export var speakersPresent:Array[Speaker]
