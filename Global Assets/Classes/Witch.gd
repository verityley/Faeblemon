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
var personality #Similar to Faeble personalities, used for determining AI behavior trees
var schedule #their placement and timing around town, unless specified by current story event
var researchReward:Array #A pool of what this witch has to offer when the player wins, can grow with time
