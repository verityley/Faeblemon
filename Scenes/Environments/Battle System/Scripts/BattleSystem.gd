extends Node3D
class_name BattleSystem

@export var stageSystem:StageSystem
@export var commandsManager:CommandsManager

@export var playerBattler:StageBattler
@export var enemyBattler:StageBattler

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
	Daze, #Prevents Rush Stance, and reduces Brawn
	Fear, #Prevents Brace Stance, and reduces Wit
	Silence, #Prevents Channel Stance, and reduces Ambition
	Slow #Prevents Stance Change, and reduces Grace
}

enum Attributes{
	Brawn=0, #Physical Attack
	Vigor, #Physical Defense
	Wit, #Magical Attack
	Ambition, #Magical Defense
	Grace, #Speed
	Heart, #Health
	Prowess, #Status Attack
	Resolve #Status Defense
}

enum Stances{
	Neutral=0,
	Rush, #Forward stance, +1 Priority
	Brace, #Defensive stance, +1 Armor
	Focus #Chanelling stance, +1 Wild Mana, -1 Priority
}

enum Mana{
	Primordial=1,
	Enchantment,
	Arcane,
	Wild
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
var playerSent:bool
var playerAction:int
var playerMenuStage:int
var enemySent:bool
var enemyAction:int
var enemyMenuStage:int


func WildBattle():
	pass

func WitchBattle():
	pass

func StaticBattle():
	pass


func BattleCleanup():
	pass


func BattleStart(pFaeble:Faeble, eFaeble:Faeble, pWitch:Witch, eWitch:Witch):
	playerFaeble = pFaeble
	enemyFaeble = eFaeble
	playerWitch = pWitch
	enemyWitch = eWitch
	playerBattler.BattlerSetup(stageSystem)
	enemyBattler.BattlerSetup(stageSystem)
	await get_tree().create_timer(1.0).timeout
	playerBattler.ChangeBattler(pFaeble)
	playerBattler.ChangeWitch(pWitch)
	enemyBattler.ChangeBattler(eFaeble)
	enemyBattler.ChangeWitch(eWitch)
	await get_tree().create_timer(1.0).timeout
	RoundStart()

func RoundStart():
	DisplayCommands(true)


func DefeatBattler(player:bool):
	pass #Hide health UI, animate death, prompt battler swap

func NextBattler(player:bool):
	pass #Show health UI, animate entry, process ChangeBattler

func AwaitInput(host:bool, action:int, stage:int):
	if vsMulti:
		if host:
			playerSent = true
			playerAction = action
			playerMenuStage = stage
		else:
			enemySent = true
			enemyAction = action
			enemyMenuStage = stage
		pass #Wait for action input from both sides
	elif vsAI:
		if host:
			playerSent = true
			playerAction = action
			playerMenuStage = stage
		pass #Send signal to AIManager to decide action
		enemySent = true
		enemyAction = action
		enemyMenuStage = stage
	
	if playerSent and enemySent:
		DisplayCommands(false)
		ProcessRound()

func ProcessRound():
	#Stage 1: Tactics, Stage 2: Cantrips, Stage 3: Moves
	var playerAttack:Skill = null
	var enemyAttack:Skill = null
	#Player Inputs
	match playerMenuStage:
		1: #Tactics Menu
			match playerAction:
				0:
					pass #Choice 0: Flee
				1:
					pass #Choice 1: Switch
				2:
					pass #Choice 2:Ritual? Item? Undecided
		2: #Witch Cantrips
			playerAttack = playerBattler.witchInstance.cantrips[playerAction]
		3: #Faeble Skills
			playerAttack = playerBattler.faebleInstance.assignedSkills[playerAction]
	
	match enemyMenuStage:
		1:
			match enemyAction:
				0:
					pass #Choice 0: Flee
				1:
					pass #Choice 1: Switch
				2:
					pass #Choice 2:Ritual? Item? Undecided
		2:
			enemyAttack = enemyBattler.witchInstance.cantrips[enemyAction]
		3:
			enemyAttack = enemyBattler.faebleInstance.assignedSkills[enemyAction]
	
	var playerFirst:bool = SpeedCalc(playerAttack,enemyAttack)
	if playerFirst:
		if playerAttack != null:
			await playerAttack.Execute(self, playerBattler, enemyBattler)
		if enemyAttack != null:
			await enemyAttack.Execute(self, enemyBattler, playerBattler)
	else:
		if enemyAttack != null:
			await enemyAttack.Execute(self, enemyBattler, playerBattler)
		if playerAttack != null:
			await playerAttack.Execute(self, playerBattler, enemyBattler)
	
	await get_tree().create_timer(1.0).timeout
	playerBattler.manaDisplay.AddMana(commandsManager.selectedMana)
	if playerBattler.stance == Stances.Focus:
		playerBattler.manaDisplay.AddMana(Mana.Wild)
	#if weather/planar phase, add mana
	#if AI call its behavior tree for mana, if wild call environment, if multi call commands input
	if enemyBattler.stance == Stances.Focus:
		enemyBattler.manaDisplay.AddMana(Mana.Wild)
	
	#TEMP
	var RNG = RandomNumberGenerator.new()
	RNG.randomize()
	var manaRNG:int = RNG.randi_range(1,3)
	enemyBattler.manaDisplay.AddMana(manaRNG)
	#END TEMP
	
	ResetRound()


func ResetRound():
	playerSent = false
	playerAction = 0
	playerMenuStage = 0
	enemySent = false
	enemyAction = 0
	enemyMenuStage = 0
	RoundStart()


func DisplayCommands(show:bool):
	var tween = get_tree().create_tween()
	var target:Vector3
	if show:
		target = Vector3(4.75,-2.25,3)
		commandsManager.show()
	else:
		target = Vector3(8,-5.5,3)
		commandsManager.FillOptions(playerBattler.faebleInstance.assignedSkills, playerBattler.witchInstance.cantrips)
		commandsManager.ResetCommandMenu()
	tween.tween_property(commandsManager, "position", target, 0.4)
	await tween.finished
	if !show:
		commandsManager.hide()


func SpeedCalc(playerAttack:Skill, enemyAttack:Skill) -> bool:
	if playerAttack == null and enemyAttack != null:
		return true
	elif playerAttack != null and enemyAttack == null:
		return false
	elif playerAttack == null and enemyAttack == null:
		var RNG = RandomNumberGenerator.new()
		RNG.randomize()
		var coinflip = RNG.randi_range(0, 1)
		if coinflip:
			return true
		else:
			return false
	var playerFirst:bool = false
	var pPriority:int = playerAttack.priority
	var ePriority:int = enemyAttack.priority
	var pSpeed:int = playerBattler.faebleInstance.grace
	pSpeed =+  playerBattler.buffStages[Attributes.Grace] * stageIncrease
	var eSpeed:int = enemyBattler.faebleInstance.grace
	eSpeed =+  enemyBattler.buffStages[Attributes.Grace] * stageIncrease
	
	if pSpeed >= eSpeed + highThreshold:
		pPriority += 2
	elif pSpeed >= eSpeed + lowThreshold:
		pPriority += 1
	elif eSpeed >= pSpeed + lowThreshold:
		ePriority += 1
	elif eSpeed >= pSpeed + highThreshold:
		ePriority += 2
	
	if playerBattler.stance == Stances.Rush:
		pPriority += 1
	elif playerBattler.stance == Stances.Focus:
		pPriority -= 1
	
	if enemyBattler.stance == Stances.Rush:
		ePriority += 1
	elif enemyBattler.stance == Stances.Focus:
		ePriority -= 1
	
	if playerAttack.witchSkill == true:
		pPriority = 10 + playerAttack.priority
	if enemyAttack.witchSkill == true:
		ePriority = 10 + enemyAttack.priority
	
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


func DamageCalc(attack:Skill, user:StageBattler, target:StageBattler) -> int: #Returns Outgoing Damage
	var tier:int = attack.damageTier - 1
	var damage:int = tierDamage[tier]
	var moveSchool:School
	var mod:float = 0
	var attacker:Faeble = user.faebleInstance
	var defender:Faeble = target.faebleInstance
	var attackerStat:int
	var defenderStat:int
	var attackerStages:Array[int] = user.buffStages.duplicate()
	var defenderStages:Array[int] = target.buffStages.duplicate()
	
		
	if attack.magical == false:
		attackerStat = attacker.brawn + (attackerStages[Attributes.Brawn] * stageIncrease)
		defenderStat = defender.vigor + (defenderStages[Attributes.Vigor] * stageIncrease)
	elif attack.magical == true:
		attackerStat = attacker.wit + (attackerStages[Attributes.Wit] * stageIncrease)
		defenderStat = defender.ambition + (defenderStages[Attributes.Ambition] * stageIncrease)
	
	if attack.school == attacker.faebleEntry.sigSchool:
		mod += schoolTB[tier]
	
	if attack.school.name == "Mimic":
		moveSchool = attacker.sigSchool
	else:
		moveSchool = attack.school
	
	if attackerStat >= defenderStat + highThreshold:
		mod += bigStatTB[tier]
	elif attackerStat >= defenderStat + lowThreshold:
		mod += smallStatTB[tier]
	elif defenderStat >= attackerStat + lowThreshold:
		mod -= smallStatTB[tier]
	elif defenderStat >= attackerStat + highThreshold:
		mod -= bigStatTB[tier]
	
	var matchupMod:int = CheckMatchups(defender, moveSchool)
	mod += matchupMod
	
	mod -= target.armor
	#user.armor = 0
	
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
