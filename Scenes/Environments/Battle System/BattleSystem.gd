extends Node3D
class_name BattleSystem

@export var playerLayer:int = 4
@export var enemyLayer:int = 7
@export var playerPoint:Vector3
@export var enemyPoint:Vector3
var layerOffset:float = 0.5

@export var playerBattler:Node3D
@export var enemyBattler:Node3D
@export var pHPDisplay:Node3D
@export var eHPDisplay:Node3D
@export var pManaDisplay:Node3D
@export var eManaDisplay:Node3D

@export var tierDamage:Array[int] = [4,8,12]
@export var tierCaps:Array[int] = [2,4,6]
@export var weaknessTB:Array[float] = [1, 1.5, 2]
@export var schoolTB:Array[float] = [0.5, 1, 1]
@export var smallStatTB:Array[float] = [0.5, 1, 1]
@export var bigStatTB:Array[float] = [1, 1.5, 2]

@export var tierStatus:Array[int] = [2,4]
@export var tierStatusCaps:Array[int] = [1,2]
@export var weaknessSTB:Array[float] = [0.5,1]
@export var schoolSTB:Array[float] = [0.5, 0.5]
@export var smallStatSTB:Array[float] = [0.5, 1]
@export var bigStatSTB:Array[float] = [1, 1.5]

@export var stageIncrease:int
@export var lowThreshold:int
@export var highThreshold:int
@export var levelBonus:float = 0.5

enum Status{
	Clear=0,
	Decay, #Tick damage, and reduces Vigor
	Charm, #Prevents moving away from source, and reduces Brawn
	Fear, #Prevents moving towards the source, and reduces Wit
	Silence, #Reduces maximum attack range (never below minimum), and reduces Ambition
	Slow #Halves stamina gain, and reduces Grace
}

enum Attributes{
	Brawn=0,
	Vigor,
	Wit,
	Ambition,
	Grace,
	Heart
}

enum Stances{
	Neutral=0,
	Rush, #Forward stance, +1 Priority
	Brace, #Defensive stance, +1 Armor
	Focus #Chanelling stance, -1 Cost, -1 Priority
}

#External Variables
var playerFaeble:Faeble
var enemyFaeble:Faeble
var playerWitch:Witch
var enemyWitch:Witch
var currentPhase:PlanarPhase
@export var vsMulti:bool
@export var vsAI:bool

#Internal Variables
var pHealth:int #Resource that means Not Dead
var pMana:int #Resource for skills
var pArmor:int #Temporary resource that goes away after an attack, soaks damage
var pBuildup:int #Status buildup amount
var pStatus:int #Enum of statuses
var pStance:int #Enum of stances
var pStages:Array[int] = [0,0,0,0,0]

var eHealth:int #Resource that means Not Dead
var eMana:int #Resource for skills
var eArmor:int #Temporary resource that goes away after an attack, soaks damage
var eBuildup:int #Status buildup amount
var eStatus:int #Enum of statuses
var eStance:int #Enum of stances
var eStages:Array[int] = [0,0,0,0,0]


func BattleSetup(stageSystem:StageSystem):
	playerBattler.reparent(stageSystem.stageLayers[playerLayer])
	playerBattler.position = playerPoint
	playerBattler.rotation.y = deg_to_rad(180)
	pHPDisplay.reparent(stageSystem.stageLayers[playerLayer])
	pHPDisplay.position = playerBattler.position
	enemyBattler.reparent(stageSystem.stageLayers[enemyLayer])
	enemyBattler.position = enemyPoint
	eHPDisplay.reparent(stageSystem.stageLayers[enemyLayer])
	eHPDisplay.position = enemyBattler.position
	eHPDisplay.rotation.y = deg_to_rad(180)


func WildBattle():
	pass

func WitchBattle():
	pass

func StaticBattle():
	pass


func BattleCleanup():
	playerBattler.reparent(self)
	pHPDisplay.reparent(self)
	enemyBattler.reparent(self)
	eHPDisplay.reparent(self)
	#hide()
	#queue_free()

func ChangeBattler(entry:Faeble, player:bool):
	var texture:Material
	if player:
		texture = playerBattler.get_child(0).get_surface_override_material(0)
		texture.albedo_texture = entry.backSprite
		playerBattler.get_child(0).set_surface_override_material(0, texture)
		playerBattler.position = playerPoint + entry.groundOffset
		playerBattler.position.z += layerOffset
		playerBattler.scale = entry.battlerScale
		pHPDisplay.position = playerBattler.position + entry.UICenter
		pHealth = entry.currentHP
		pStatus = entry.currentStatus
		pBuildup = entry.currentBuildup
	else:
		texture = enemyBattler.get_child(0).get_surface_override_material(0)
		texture.albedo_texture = entry.sprite
		enemyBattler.get_child(0).set_surface_override_material(0, texture)
		enemyBattler.position = enemyPoint + entry.groundOffset
		enemyBattler.position.z += layerOffset
		enemyBattler.scale = entry.battlerScale
		eHPDisplay.position = enemyBattler.position + entry.UICenter
		eHealth = entry.currentHP
		eStatus = entry.currentStatus
		eBuildup = entry.currentBuildup
	


func ChangeWitch(witch:Witch, player:bool, layer:Node3D):
	pass


func SpeedCalc(playerAttack:Skill, enemyAttack:Skill) -> bool:
	var playerFirst:bool = false
	var pPriority:int = playerAttack.priority
	var ePriority:int = enemyAttack.priority
	var pSpeed:int = playerFaeble.grace + (pStages[Attributes.Grace] * stageIncrease)
	var eSpeed:int = enemyFaeble.grace + (eStages[Attributes.Grace] * stageIncrease)
	
	if pSpeed >= eSpeed + highThreshold:
		pPriority += 2
	elif pSpeed >= eSpeed + lowThreshold:
		pPriority += 1
	elif eSpeed >= pSpeed + lowThreshold:
		ePriority += 1
	elif eSpeed >= pSpeed + highThreshold:
		ePriority += 2
	
	if pStance == Stances.Rush:
		pPriority += 1
	elif pStance == Stances.Focus:
		pPriority -= 1
	
	if eStance == Stances.Rush:
		ePriority += 1
	elif eStance == Stances.Focus:
		ePriority -= 1
	
	if pPriority > ePriority:
		playerFirst = true
	elif pPriority < ePriority:
		playerFirst = false
	else:
		var RNG = RandomNumberGenerator.new()
		RNG.randomize()
		var coinflip = RNG.randi_range(0, 1)
		if coinflip:
			playerFirst = true
		else:
			playerFirst = false
	return playerFirst


func DamageCalc(attack:Skill, player:bool) -> int: #Returns Outgoing Damage
	var tier:int = attack.damageTier - 1
	var damage:int = tierDamage[tier]
	var mod:float = 0
	var attacker:Faeble
	var defender:Faeble
	var attackerStat:int
	var defenderStat:int
	var attackerStages:Array[int]
	var defenderStages:Array[int]
	
	if player:
		attacker = playerFaeble
		attackerStages = pStages.duplicate()
		defender = enemyFaeble
		defenderStages = eStages.duplicate()
	else:
		attacker = enemyFaeble
		attackerStages = eStages.duplicate()
		defender = playerFaeble
		defenderStages = pStages.duplicate()
		
	if attack.magical == false:
		attackerStat = attacker.brawn + (attackerStages[Attributes.Brawn] * stageIncrease)
		defenderStat = defender.vigor + (defenderStages[Attributes.Vigor] * stageIncrease)
	elif attack.magical == true:
		attackerStat = attacker.wit + (attackerStages[Attributes.Wit] * stageIncrease)
		defenderStat = defender.ambition + (defenderStages[Attributes.Ambition] * stageIncrease)
	
	if attack.skillType == attacker.faebleEntry.sigSchool:
		mod += schoolTB[tier]
	
	if attackerStat >= defenderStat + highThreshold:
		mod += bigStatTB[tier]
	elif attackerStat >= defenderStat + lowThreshold:
		mod += smallStatTB[tier]
	elif defenderStat >= attackerStat + lowThreshold:
		mod -= smallStatTB[tier]
	elif defenderStat >= attackerStat + highThreshold:
		mod -= bigStatTB[tier]
	
	var matchupMod:int = CheckMatchups(defender, attack.skillType)
	mod += matchupMod
	
	if player:
		mod -= eArmor
		eArmor = 0
	elif !player:
		mod -= pArmor
		pArmor = 0
	
	mod = clamp(mod, tierDamage[tier]-tierCaps[tier], tierDamage[tier]+tierCaps[tier])
	
	
	if attacker.chapter > defender.chapter:
		mod += ((attacker.chapter - defender.chapter) * levelBonus)
	elif attacker.chapter < defender.chapter:
		mod += ((defender.chapter - attacker.chapter) * levelBonus)
	
	mod = floori(mod)
	damage += mod
	damage = clampi(damage, 1, 60)
	print("Final Damage: ", damage)
	return damage


func CheckMatchups(target:Faeble, attackingType:School) -> int: #Returns multiplier int
	var mod:int #Output
	var damageMultiplier:int = 1 #Running tally of adjustment multiplier (affects variable below)
	var damageAdjustment:int = 0 #Running tally of resistance "stage"
	# Import types for defenses
	var firstType:Domain = target.firstDomain 
	var secondType:Domain = target.secondDomain
	var signatureType:School = target.sigSchool
	
	if firstType != null: #Get first type matchup index for attacking type
		if firstType.typeMatchups.has(attackingType):
			damageAdjustment += firstType.typeMatchups[attackingType]
			#print(firstType.name)
	
	if secondType != null: #Get second type matchup index for attacking type
		if secondType.typeMatchups.has(attackingType):
			damageAdjustment += secondType.typeMatchups[attackingType]
			#print(secondType.name)
	
	if signatureType != null:
	#If the signature school of this monster equals the attacking type, add a step of resistance
		if attackingType == signatureType:
			damageAdjustment -= 1
	
	if attackingType.name == "Weird" and currentPhase != null:
	#Increment Weird if any planar phase is present
		damageAdjustment += 1
	elif attackingType.name != "Weird" and currentPhase != null:
	#If a planar status is present, check for relevency and multiplier/additive adjustment
		if currentPhase.adjustAdditive == true: #If additive, apply to Adjustment
			if currentPhase.typeList.has(attackingType) or currentPhase.allTypes == true:
				damageAdjustment += currentPhase.addPosi
			else:
				damageAdjustment += currentPhase.addNega
			
		if currentPhase.adjustMulti == true: #If multiplicative, apply to multiplier
			if currentPhase.typeList.has(attackingType) or currentPhase.allTypes == true:
				damageMultiplier *= currentPhase.multiPosi
			else:
				damageMultiplier *= currentPhase.multiNega
	
	mod = damageAdjustment * damageMultiplier
	return mod
