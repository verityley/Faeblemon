extends Node3D
class_name BattleSystem

@export var testFaeble1:Faeble
@export var testFaeble2:Faeble

#External Variables
var playerFaeble:Faeble
var enemyFaeble:Faeble
var playerWitch:Witch
var enemyWitch:Witch
var currentPhase:PlanarPhase
@export var vsMulti:bool
@export var vsAI:bool

#Setup Variables
@export_category("Managers")
@export var commandManager:Node3D
@export var multiplayerManager:Node3D
@export var AIManager:Node3D
@export var displayManager:DisplayManager
@export var fieldManager:FieldManager
@export var messageManager:Node3D
@export var fxManager:Node3D
@export var propManager:Node3D
@onready var camera_3d = $Environment/FXManager/Camera3D


@export_category("Combat Parameters")
@export var highThreshold:int = 5
@export var lowThreshold:int = 3
@export var stageIncrease:int = 2
@export var highDiffBonus:int = 2 #How much damage is added if highThresh crossed
@export var lowDiffBonus:int = 1
@export var weaknessBonus:int = 1
@export var sigSchoolBonus:int = 1
@export var chargeBonus:int = 1
@export var guardPenalty:int = 2
@export var nearMissPenalty:int = 2
@export var missPenalty:int = 4
@export var startingStamina:int = 4
@export var staminaBonus:int = 1

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

enum Actions{
	Attack=1,
	Guard,
	Recharge,
	Dash,
	Switch
}

#Internal Variables
var pHealth:int #Resource that means Not Dead
var pMana:int #Resource for skills
var pResolve:int #Armor against attacks
var pStamina:int #Available movepoints
var pBuildup:int #Status buildup amount
var pStatus:int #Enum of statuses
var pGuarding:bool
var pCharging:bool
var pStages:Array[int] = [0,0,0,0,0]

var eHealth:int #Resource that means Not Dead
var eMana:int #Resource for skills
var eResolve:int #Armor against attacks
var eStamina:int #Available movepoints
var eBuildup:int #Status buildup amount
var eStatus:int #Enum of statuses
var eGuarding:bool
var eCharging:bool
var eStages:Array[int] = [0,0,0,0,0]

var playerSent:bool
var playerAction:int
var playerMovement:int
var playerExtras:Array[int]
var enemySent:bool
var enemyAction:int
var enemyMovement:int
var enemyExtras:Array[int]
var actionOrder:Array[int]
var actionUser:Array[bool]
@export var simulMove:bool

#Setup Functions
func _ready():
	BattleInit()

func BattleInit():
	playerFaeble = FaebleCreation.CreateFaeble(testFaeble1, 4) #TEMP, REPLACE LATER
	enemyFaeble = FaebleCreation.CreateFaeble(testFaeble2, 4)
	
	displayManager.ChangeMax(displayManager.Resources.Health, playerFaeble.maxHP,true)
	displayManager.ChangeMax(displayManager.Resources.Mana,
	playerFaeble.maxMana + playerFaeble.manaBonus,true)
	displayManager.ChangeMax(displayManager.Resources.Resolve,
	playerFaeble.maxResolve + playerFaeble.resolveBonus,true)
	
	displayManager.ChangeMax(displayManager.Resources.Health, enemyFaeble.maxHP,false)
	displayManager.ChangeMax(displayManager.Resources.Mana,
	enemyFaeble.maxMana + enemyFaeble.manaBonus,false)
	displayManager.ChangeMax(displayManager.Resources.Resolve,
	enemyFaeble.maxResolve + enemyFaeble.resolveBonus,false)
	
	pHealth = playerFaeble.currentHP
	pMana = playerFaeble.currentMana
	pResolve = playerFaeble.maxResolve/2
	pStamina = startingStamina
	pStatus = Status.Clear
	pBuildup = 0
	
	eHealth = enemyFaeble.currentHP
	eMana = enemyFaeble.currentMana
	eResolve = enemyFaeble.maxResolve/2
	eStamina = startingStamina
	eStatus = Status.Clear
	eBuildup = 0
	
	displayManager.ChangeCurrent(displayManager.Resources.Health, pHealth, true)
	displayManager.ChangeCurrent(displayManager.Resources.Mana, pMana, true)
	displayManager.ChangeCurrent(displayManager.Resources.Resolve, pResolve, true)
	
	displayManager.ChangeCurrent(displayManager.Resources.Health, eHealth, false)
	displayManager.ChangeCurrent(displayManager.Resources.Mana, eMana, false)
	displayManager.ChangeCurrent(displayManager.Resources.Resolve, eResolve, false)
	
	displayManager.ChangeActions(pStamina, true)
	displayManager.ChangeActions(eStamina, false)
	
	fieldManager.ChangeFaeble(playerFaeble,true)
	fieldManager.ChangeFaeble(enemyFaeble,false)
	fieldManager.ChangePositions(fieldManager.maxDistance)
	await camera_3d.StartupSequence() #ALSO TEMP
	await fieldManager.ChangeDistance(-5)
	#TEMP BELOW HERE
	#await get_tree().create_timer(1.0).timeout
	#AwaitInput(true, 4, -3)
	#await get_tree().create_timer(0.1).timeout
	#AwaitInput(false, 4, 2)

#Process Functions


#region Data-Handling Functions
func DamageCalc(attack:Skill, player:bool) -> int: #Returns Outgoing Damage
	var damage:int = attack.skillDamage
	var attacker:Faeble
	var defender:Faeble
	var charge:bool
	var guard:bool
	var attackerStat:int
	var defenderStat:int
	var attackerStages:Array[int]
	var defenderStages:Array[int]
	if player:
		attacker = playerFaeble
		attackerStages = pStages.duplicate()
		charge = pCharging
		damage *= playerFaeble.powerBonus
		defender = enemyFaeble
		defenderStages = eStages.duplicate()
		guard = eGuarding
	else:
		attacker = enemyFaeble
		attackerStages = eStages.duplicate()
		charge = eCharging
		damage *= enemyFaeble.powerBonus
		defender = playerFaeble
		defenderStages = pStages.duplicate()
		guard = pGuarding
		
	if attack.skillNature == "Physical":
		attackerStat = attacker.brawn + (attackerStages[Attributes.Brawn] * stageIncrease)
		defenderStat = defender.vigor + (defenderStages[Attributes.Vigor] * stageIncrease)
	elif attack.skillNature == "Magical":
		attackerStat = attacker.wit + (attackerStages[Attributes.Wit] * stageIncrease)
		defenderStat = defender.ambition + (defenderStages[Attributes.Ambition] * stageIncrease)
	else:
		print("Error! Invalid damage type!")
	
	if attack.skillType == attacker.faebleEntry.sigSchool:
		damage += sigSchoolBonus
	if charge:
		damage += chargeBonus
		charge = false
	if guard:
		damage -= guardPenalty
		guard = false
	
	
	if attackerStat >= defenderStat + highThreshold:
		damage += highDiffBonus
	elif attackerStat >= defenderStat + lowThreshold:
		damage += lowDiffBonus
	elif defenderStat >= attackerStat + lowThreshold:
		damage -= lowDiffBonus
	elif defenderStat >= attackerStat + highThreshold:
		damage -= highDiffBonus
	prints("Post Stats Damage:", damage,
	"Attacker Stat:", attackerStat, "Defender Stat:", defenderStat)
	
	var matchupMod:int = CheckMatchups(defender.faebleEntry, attack.skillType)
	prints("Matchup Changing by:", matchupMod)
	damage += (matchupMod * weaknessBonus)
	
	if fieldManager.combatDistance == attack.rangeMax + 1:
		damage -= nearMissPenalty
	elif fieldManager.combatDistance == attack.rangeMin - 1:
		damage -= nearMissPenalty
	elif fieldManager.combatDistance > attack.rangeMax + 1:
		damage -= missPenalty
	elif fieldManager.combatDistance < attack.rangeMin - 1:
		damage -= missPenalty
	
	damage = clampi(damage, 1, 99)
	print("Final Damage: ", damage)
	
	if player:
		pCharging = charge
		eGuarding = guard
	else:
		eCharging = charge
		pGuarding = guard
	
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

#endregion


#Tangible Action Functions


#State Machine
func AwaitInput(host:bool, action:int, movement:int=0, extras:Array[int]=[]):
	if vsMulti:
		if host:
			playerSent = true
			playerAction = action
			playerMovement = movement
			playerExtras = extras
		else:
			enemySent = true
			enemyAction = action
			enemyMovement = movement
			enemyExtras = extras
		pass #Wait for action input from both sides
	elif vsAI:
		if host:
			playerSent = true
			playerAction = action
			playerMovement = movement
			playerExtras = extras
		pass #Send signal to AIManager to decide action
		enemySent = true
		enemyAction = action
		enemyMovement = movement
		enemyExtras = extras
	
	if playerSent and enemySent:
		ProcessRound()

func ProcessRound():
	print("Beginning Round Action")
	if simulMove:
		pStamina -= abs(playerMovement)
		eStamina -= abs(enemyMovement)
		prints("PMove:",playerMovement,"EMove:",enemyMovement)
		var movement:int = playerMovement + enemyMovement
		displayManager.ChangeActions(pStamina, true)
		displayManager.ChangeActions(eStamina, false)
		print("Total Movement: ", movement)
		#displayManager.ChangeCurrent(displayManager.Resources.Resolve, movement, player, true)
		await fieldManager.ChangeDistance(movement)
	await QueueActions()
	for i in range(actionOrder.size()):
		if !simulMove:
			if actionUser[i]:
				print(playerMovement)
				await TurnMovement(playerMovement, true)
			else:
				print(enemyMovement)
				await TurnMovement(enemyMovement, false)
		await get_tree().create_timer(1.0).timeout
		await TurnAction(actionOrder[i], actionUser[i])
		await get_tree().create_timer(2.0).timeout

func QueueActions():
	var RNG = RandomNumberGenerator.new()
	var playerSpeed:int = playerFaeble.grace + (pStamina * staminaBonus)
	var enemySpeed:int = enemyFaeble.grace + (eStamina * staminaBonus)
	if playerSpeed > enemySpeed:
		actionOrder.append(playerAction)
		actionUser.append(true)
		actionOrder.append(enemyAction)
		actionUser.append(false)
	elif enemySpeed > playerSpeed:
		actionOrder.append(enemyAction)
		actionUser.append(false)
		actionOrder.append(playerAction)
		actionUser.append(true)
	elif playerSpeed == enemySpeed: #Use stamina for tiebreaker
		if pStamina > eStamina:
			actionOrder.append(playerAction)
			actionUser.append(true)
			actionOrder.append(enemyAction)
			actionUser.append(false)
		elif eStamina > pStamina:
			actionOrder.append(enemyAction)
			actionUser.append(false)
			actionOrder.append(playerAction)
			actionUser.append(true)
		elif pStamina == eStamina: #Use RNG for final tiebreaker
			if RNG.randi_range(0,1) == 1:
				actionOrder.append(playerAction)
				actionUser.append(true)
				actionOrder.append(enemyAction)
				actionUser.append(false)
			else:
				actionOrder.append(enemyAction)
				actionUser.append(false)
				actionOrder.append(playerAction)
				actionUser.append(true)



#func SubmitExtraInput():
	#var actionQueue:Array = QueueActions(0,0)
	#pass #Wait for signal, assign to variable, if both variables assigned, queue actions and begin

func TurnMovement(movement:int, player:bool):
	if movement != 0:
		#Implement status effect check here, for fear and charm
		var stamina:int
		if player:
			stamina = pStamina
		else:
			stamina = eStamina
		displayManager.ChangeActions(stamina - abs(movement),player)
		#displayManager.ChangeCurrent(displayManager.Resources.Resolve, movement, player, true)
		await fieldManager.MoveFaeble(movement, player)
		#await fieldManager.ChangeDistance(movement)
		if player:
			pStamina = stamina - abs(movement)
		else:
			eStamina = stamina - abs(movement)

func TurnAction(action:int, player:bool):
	match action:
		Actions.Attack:
			if player:
				#TEMP, Change to attack selection
				await AttackAction(playerFaeble.assignedSkills[0], player)
			else:
				await AttackAction(enemyFaeble.assignedSkills[0], player)
		Actions.Guard:
			await GuardAction(player)
		Actions.Recharge:
			await RechargeAction(player)
		Actions.Dash:
			await DashAction(2, player) #TEMP VALUE
		Actions.Switch:
			pass

func AttackAction(attack:Skill, player:bool):
	pass #Execute() skill specific mechanics, then run damage calc, reduce resolve then hp
	var damage:int
	if player:
		pMana -= attack.skillCost
		displayManager.ChangeCurrent(displayManager.Resources.Mana, pMana, player, true)
	else:
		eMana -= attack.skillCost
		displayManager.ChangeCurrent(displayManager.Resources.Mana, eMana, player, true)
	if attack.skillDamage > 0:
		damage = DamageCalc(attack, player)
		if player:
			if damage > eResolve:
				damage -= eResolve
				eResolve = 0
			else:
				eResolve -= damage
			displayManager.ChangeCurrent(displayManager.Resources.Resolve, eResolve, !player, true)
			if damage > 0:
				eHealth -= clampi(eHealth-damage, 0, enemyFaeble.maxHP)
				displayManager.ChangeCurrent(displayManager.Resources.Health, eHealth, !player, true)
		else:
			if damage > pResolve:
				damage -= pResolve
				pResolve = 0
			else:
				pResolve -= damage
			displayManager.ChangeCurrent(displayManager.Resources.Resolve, pResolve, !player, true)
			if damage > 0:
				pHealth -= clampi(pHealth-damage, 0, playerFaeble.maxHP)
				displayManager.ChangeCurrent(displayManager.Resources.Health, pHealth, !player, true)

func GuardAction(player:bool):
	if player:
		pResolve = playerFaeble.maxResolve
		displayManager.ChangeCurrent(displayManager.Resources.Resolve, pResolve, player, true)
		pGuarding = true
	else:
		eResolve = enemyFaeble.maxResolve
		displayManager.ChangeCurrent(displayManager.Resources.Resolve, eResolve, player, true)
		eGuarding = true
	pass #Refills Resolve, and reduces damage of next incoming attack

func RechargeAction(player:bool):
	if player:
		pMana = playerFaeble.maxMana
		displayManager.ChangeCurrent(displayManager.Resources.Mana, pMana, player, true)
		pCharging = true
	else:
		eMana = enemyFaeble.maxMana
		displayManager.ChangeCurrent(displayManager.Resources.Mana, eMana, player, true)
		eCharging = true
	pass #Refills mana, then empowers next attack. Maybe makes next attack free too?

func DashAction(amount:int, player:bool):
	fieldManager.ChangeDistance(amount)
	pass #Additional movement of a set amount, ends turn unlike normal movement.

func SwitchAction(target:Faeble, player:bool):
	pass

#placeholder order of operations:
#Battle start, play intro while swapping faebles to current party/encounter
#Determine if witch vs witch, display alt intro and enable witch actions
#Fold down status plates, display randomized research goals
#Show player UI
#On selection, queue action for turn order
#When both sides selected (or player selected and AI responded), move to turn order
#Turn determined by stamina and speed differences
#Enact queued actions and change relevant resources
#Cleanup, research goal check, restart
