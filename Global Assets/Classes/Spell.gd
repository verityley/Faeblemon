extends Resource
class_name Spell

@export var name:String
@export var school:School
@export var magical:bool #if true, use magic stat
@export var priority:int
@export var pGuarding:bool
@export var mGuarding:bool
@export var rangeBands:Array[bool] = [false,false,false]
@export_range(0,3) var damageTier:int
@export var statusType:Enums.Status
@export_range(0,2) var statusTier:int
@export var buffStat:Enums.BuffableAttrs = Enums.BuffableAttrs.None
@export_range(0,2) var buffAmount:int
@export var buffTarget:bool = false
@export_range(-3,3) var movement:int = 0
@export var recoil:int = 0 #If negative, treat as healing
@export var recoilPercent:float = 0.0
@export var auraActivate:Aura
@export var witchSpell:bool #If true, this skill is cast from a witch

@export var movePreview:CompressedTexture2D
@export var moveDisplay:CompressedTexture2D
@export_multiline var moveDescription:String
#@export var skillAnim:AnimatedSprite2D


func BeforeSpell(system:BattleSystemFINAL, user:BattlerData, target:BattlerData) -> bool:
	#conditional effect handling if present on attack
	var conditional:bool = true
	return conditional

func ExecuteSpell(user:BattlerData, target:BattlerData, range:int, aura:Aura = null):
	#if target is same as self, skip attack process and go to self-buff stage increases/heals/shields
	#if target is empty, skip attack and self-state process and go to world-state change, like auras
	#if target is different, process as attack, check damage if present, then status if present
	#damage and buildup handling
	if damageTier > 0:
		DefaultDamage(user, target, range, aura)
	if statusTier > 0:
		DefaultStatus(user, target, range, aura)
	

func AfterSpell(user:BattlerData, target:BattlerData):
	#stage buff handling
	#heal/cleanse handling
	#world state handling
	#handle switch outs
	if recoil != 0 or recoilPercent != 0.0:
		DefaultRecoil(user,target)
	if buffAmount != 0:
		if buffTarget:
			DefaultBuffs(target)
		else:
			DefaultBuffs(user)

func DefaultDamage(user:BattlerData, target:BattlerData, range:int, aura:Aura = null):
	var results:Dictionary = BattleCalcs.DamageCalc(self,user,target,range,aura).duplicate()
	var damage:int = results["Damage"]
	#Insert signal for battle animation
	#Insert signal for super effective hit
	#Insert signal for missed attack
	target.health = clampi(target.health-damage, 0, target.instance.maxHP)
	target.damageTaken += damage
	prints(target.instance.name,"took",damage,"damage!",target.instance.name,"has",target.health,"remaining.")
	EventBus.emit_signal("HealthChanged", target)

func DefaultStatus(user:BattlerData, target:BattlerData, range:int, aura:Aura = null):
	var results:Dictionary = BattleCalcs.StatusCalc(self,user,target,range,aura).duplicate()
	var buildup:int = results["Buildup"]
	if target.buildupTarget == statusType or target.buildupTarget == Enums.Status.Clear:
		target.buildupTarget = statusType
		EventBus.emit_signal("StatusChanged", target, false)
		target.buildup = clampi(target.buildup+buildup, 0, target.instance.maxBuildup)
	else:
		if statusType == Enums.Status.Catalyze:
			if target.buildupTarget != Enums.Status.Clear:
				target.buildup = clampi(target.buildup+buildup, 0, target.instance.maxBuildup)
		elif target.buildup < target.instance.maxBuildup/2:
			target.buildupTarget = statusType
			EventBus.emit_signal("StatusChanged", target, false)
			target.buildup = clampi(target.buildup+buildup, 0, target.instance.maxBuildup)
		elif target.buildup >= floori(target.instance.maxBuildup/2):
			target.buildup = clampi(target.buildup+floori(buildup/2), 0, target.instance.maxBuildup)
	EventBus.emit_signal("BuildupChanged", target)
	#After buildup processing, check if status is afflicted
	if target.buildup == target.instance.maxBuildup:
		target.status = target.buildupTarget
		EventBus.emit_signal("StatusChanged", target, true)
	prints(target.instance.name,"took",buildup,"buildup of",Enums.Status.keys()[statusType])

func DefaultBuffs(target:BattlerData):
	target.buffStages[buffStat] = clampi(target.buffStages[buffStat]+buffAmount,-BattleCalcs.maxStages,BattleCalcs.maxStages)
	if buffAmount > 0:
		prints(target.instance.name,"'s'",Enums.BuffableAttrs.keys()[buffStat],"rose by",buffAmount,"stages!")
	elif buffAmount < 0:
		prints(target.instance.name,"'s'",Enums.BuffableAttrs.keys()[buffStat],"lowered by",buffAmount,"stages!")

func DefaultRecoil(user:BattlerData, target:BattlerData):
	if recoilPercent > 0.0:
		var damage:int = ceili(float(target.damageTaken)*recoilPercent)
		user.health = clampi(user.health-damage, 0, user.instance.maxHP)
		user.damageTaken += damage
		prints(user.instance.name,"took",damage,"recoil!")
		EventBus.emit_signal("HealthChanged", user)
	elif recoilPercent < 0.0:
		var drain:int = ceili(float(target.damageTaken)*abs(recoilPercent))
		user.health = clampi(user.health+drain, 0, user.instance.maxHP)
		user.damageTaken -= drain
		prints(user.instance.name,"healed for",drain,"!")
		EventBus.emit_signal("HealthChanged", user)
	if recoil > 0:
		user.health = clampi(user.health-recoil, 0, user.instance.maxHP)
		user.damageTaken += recoil
		prints(user.instance.name,"took",recoil,"recoil!")
		EventBus.emit_signal("HealthChanged", user)
	elif recoil < 0:
		user.health = clampi(user.health-recoil, 0, user.instance.maxHP)
		user.damageTaken += recoil
		prints(user.instance.name,"healed for",-recoil,"!")
		EventBus.emit_signal("HealthChanged", user)
