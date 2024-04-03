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
@export var battlerScale:float #Scale used in battle scenes
@export var worldScale:float #Scale used in world or city scenes
@export var UIScale:float #Scale used in UI elements
@export var groundOffset:Vector3 #How far to offset from center


@export_category("Base Stats")
var level:int = 1 #Called "Chapter" in game.
var tier:int #Used to determine bonus amounts, city needs, etc. Called "Act" in game.
var traitImprovements:int = 0
var hpIncreases:int = 1 #Always start with 1 base, for first level
var energyIncreases:int = 0
@export var minQuality:int = 2
@export var maxQuality:int = 20 #Stage increases can exceed, but only temporary
@export var brawn:int #Used for physical attacks
@export var vigor:int #Defends against physical attacks
@export var wit:int #Used for spell attacks
@export var ambition:int #Defends against spell attacks
@export var grace:int #Determines turn order
@export var resolve:int #Defends against status effect buildup
@export var heart:int #Determines your base starting HP

@export var profArray:Array[int] = [0, 0, 0, 0, 0, 0, 0]
@export var prefPrimary:String #Used for wild ASIs
@export var prefSecondary:String

@export_category("Combat Parameters")
var maxHP:int = 1
var maxEnergy:int = 1
@export var skillPool:Dictionary
@export var assignedSkills:Array[Skill] = [null, null, null, null]
var learnedSkills:Array[Skill] #These are all the skills they know by their level, or with Scrolls
@export var feats:Array[Feat]
@export var traitBig:bool #This Faeble takes up the entire column of the battlefield
@export var traitTall:bool #This Faeble blocks jumping or flying above it
@export var traitSmall:bool #This Faeble can move through Big or Tall foes
@export var traitJumping:bool #This Faeble can move through the aerial lane, but not stay.
@export var traitFlying:bool #This Faeble stays in the aerial lane, but can't block behind on the ground.
@export var traitPhasing:bool #This can move through others regardless of traits but cannot block enemies.

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
@export var currentStamina:int #This determines how many after-battle heals a faeble has left.
@export var fainted:bool

@export_category("Description")
@export_multiline var description:String #Look into parsing string and revealing bits by level
@export_multiline var rumors:String

