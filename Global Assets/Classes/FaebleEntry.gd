extends Resource
class_name Faeble
#This resource should ONLY be read only, never adjust any of these values.
@export_category("Overview")
@export var name:String
@export var ID:int
@export var firstDomain:Domain
@export var secondDomain:Domain
@export var sigSchool:School

@export var altSigSchool1:School
@export var altSigSchool2:School

@export_category("Visual Parameters")
@export var sprite:CompressedTexture2D
@export var shinySprite:CompressedTexture2D
@export var UISprite:Texture2D
@export var icon:CompressedTexture2D
@export var battlerScale:Vector3 #Scale used in battle scenes 0.5 - 1.8
@export var worldScale:float #Scale used in world or city scenes
@export var UIScale:float #Scale used in UI elements
@export var groundOffset:Vector3 #How far to offset from center
@export var commandOffset:float



@export_category("Base Stats")
var chapter:int = 1 #Increased by battle, bonding, etc. Determines ASIs within listed stats as max.
var act:int #Increased by research, determines overall faeble unlock progress.
@export var minQuality:int = 1
@export var maxQuality:int = 20 #Stage increases can exceed, but only temporary
@export var brawn:int #Used for physical attacks
@export var vigor:int #Defends against physical attacks
@export var wit:int #Used for spell attacks
@export var ambition:int #Defends against spell attacks
@export var grace:int #Determines turn order
@export var heart:int #Determines your base starting HP

@export var profArray:Array[int] = [0, 0, 0, 0, 0, 0]
@export var statImprovements:Array[int] = [0, 0, 0, 0, 0, 0]
@export var roomToGrow:Array[int] = [0, 0, 0, 0, 0, 0]
@export var prefPrimary:String #Used for wild ASIs
@export var prefSecondary:String

@export_category("Combat Parameters")
@export var HPCap:int = 40
var maxHP:int = 1
var maxMana:int = 1
var maxResolve:int = 1
@export var powerBonus:int = 1
@export var manaBonus:int = 0
@export var resolveBonus:int = 0
@export var skillPool:Dictionary
@export var assignedSkills:Array[Skill] = [null, null, null]
var learnedSkills:Array[Skill] #These are all the skills they know by their level, or with Scrolls
@export var feats:Array[Feat]
@export var customResource:int #Used for faebles with unique mechanics to their moves
@export var customName:String #Name of custom resource

@export_category("Capture Parameters")
@export var centerPosition:Vector3
@export var colliderShape:PackedVector2Array
@export var idealZoom:float


@export_category("Evolution Parameters")
@export var canEvolve:bool
@export var evoTarget:Faeble
@export var evoLevel:int #If 0, disable evolution via level up
@export var evoStatus:StatusEffect #if null, doesn't evolve via status
#evolve via: higher level fighter, lower level fighter, captured enemy, knows move, location, party members present
#Consider using inheritance classes for evo methods, and having them share the same function call
@export var evoBranch:bool

@export_category("Instance-Only Parameters")
@export var currentHP:int
@export var currentMana:int #This determines how many after-battle heals a faeble has left.
#@export var currentResolve:int #Shouldnt need to be used I think? since resets every battle
@export var fainted:bool

@export_category("Description")
@export_multiline var description:String #Look into parsing string and revealing bits by level
@export_multiline var tags:Array[String]
@export_multiline var rumors:Array[String]

