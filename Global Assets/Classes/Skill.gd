extends Resource
class_name Skill

@export var skillName:String
@export var skillType:School
@export var skillCost:int #1 to 10
@export var skillNature:String #Physical, Magical, etc. Determines stat used.
@export var commandDifficulty:int #This is a measure of how difficult the minigame should scale
@export var commandTiming:int #This determines how fast or slow the action command minigame is

@export_multiline var moveDescription:String
#@export var skillAnim:AnimatedSprite2D

@export_category("Battlefield Traits")
@export var targetType:String #Ally, Enemy, All, etc
@export var targetScope:String #Single, AoE, etc
@export var rangeMin:int = 0
@export var rangeMax:int = 10
@export var canPierce:bool = true
@export var canArc:bool = true
