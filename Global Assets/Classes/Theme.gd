extends Resource
class_name SpellTheme

@export var name:String

@export_category("Universal Factors")
@export var priority:int
@export var pGuarding:bool
@export var mGuarding:bool
@export var buildupBoost:int
@export var movement:int
@export var recoilDamage:int
@export var damageBoost:int

@export_category("Unique Factors")
@export var damageCapMod:int
@export var buffStat:Enums.BuffableAttrs = -1
@export var buffStages:int
@export var aura:Aura
@export var statusEffect:Enums.Status
@export var rangeBands:Array[bool] = [false, false, false]
@export var rangeReplace:bool = false


func ApplyUnique(user:BattlerData):
	pass
