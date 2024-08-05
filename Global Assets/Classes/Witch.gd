extends Resource
class_name Witch

@export var name:String
@export var party:Array[Faeble] = [null,null,null,null,null,null]
@export var sprite:CompressedTexture2D
@export var portrait:CompressedTexture2D
var spellSlot1
var spellSlot2
var spellSlot3

#AI NPC Only
var personality
