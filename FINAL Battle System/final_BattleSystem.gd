extends Node
class_name BattleSystemFINAL

@export var playerBattler:BattlerData
@export var enemyBattler:BattlerData

var playerSent:bool
var enemySent:bool

var currentRange:Enums.Ranges
var currentOrder:Array[BattlerData]

@export var currentStep:BattleSteps

enum BattleSteps {
	Startup=0,
	ActionSelect,
	RoundStart,
	BeforeAll,
	BeforeFirst,
	DuringFirst,
	AfterFirst,
	BeforeSecond,
	DuringSecond,
	AfterSecond,
	Cleanup,
	Recycle
}

enum MenuActions {
	Back=-1,
	Attack,
	Spell,
	Tactics
}

func ProcessSkill(skill:Skill, user:BattlerData, target:BattlerData):
	pass
	#if target is same as self, skip attack process and go to self-buff stage increases/heals/shields
	#if target is empty, skip attack and self-state process and go to world-state change, like auras
	#if target is different, process as attack, check damage if present, then status if present
	#conditional effect handling if present on attack
	#damage and buildup handling
	#stage buff handling
	#heal/cleanse handling
	#world state handling
	#handle switch outs

func AwaitSelection(battler:BattlerData, action:MenuActions, option:int=-1, detail:int=-1):
	if action == MenuActions.Back:
		return
	
	if battler == playerBattler: playerSent = true
	elif battler == enemyBattler: enemySent = true
	
	match action:
		MenuActions.Attack:
			battler.currentMove = battler.instance.assignedSkills[option] #Assign Move
			if detail == 3: #Assign own Theme if option 4 picked
				battler.currentTheme = battler.instance.setTheme
			elif detail != -1: #Otherwise select from Witch Themes
				battler.currentTheme = battler.witchInstance.assignedThemes[detail]
			#Determine other default target
			if battler == playerBattler: battler.currentTarget = enemyBattler
			elif battler == enemyBattler: battler.currentTarget = playerBattler
			RoundStep()
		
		MenuActions.Spell:
			battler.currentSpell = battler.witchInstance.assignedSpells[option] #Assign Spell
			if detail != -1: #If no detail, no extra Faeble target
				battler.currentTarget = battler
				battler.currentFaeble = battler.faebleTeam[detail]
			else: #Determine other default target
				if battler == playerBattler: battler.currentTarget = enemyBattler
				elif battler == enemyBattler: battler.currentTarget = playerBattler
			RoundStep()
		
		MenuActions.Tactics:
			battler.currentTactic = option
			if option == 0: #Switch
				battler.currentFaeble = battler.faebleTeam[detail]
			elif option == 1: #Flee
				pass
			RoundStep()

func RoundStep():
	match currentStep:
		BattleSteps.Startup:
			pass #Start of Turn, pre-selection actions, open menu:
		
		BattleSteps.ActionSelect:
			if playerSent and enemySent:
				currentStep = BattleSteps.RoundStart
				EventBus.emit_signal("BattleStateChanged", currentStep)
				RoundStep()
			pass #Awaiting selection from both parties, then set actions to battlers
		
		BattleSteps.RoundStart:
			#Apply unique theme conditionals/effects that can't happen in turn order
			if playerBattler.currentTheme != null:
				playerBattler.currentTheme.ApplyUnique(playerBattler)
			if enemyBattler.currentTheme != null:
				enemyBattler.currentTheme.ApplyUnique(enemyBattler)
				
			#Determine Priority and Turn Order
			var priorities:Array[int] = BattleCalcs.SpeedCalc(playerBattler,enemyBattler)
			playerBattler.priority += priorities[0]
			enemyBattler.priority += priorities[1]
			currentOrder = BattleCalcs.TurnCalc(playerBattler,enemyBattler)
			
			#Determine Armor of combatants
			var playerGuards:Array[int] = BattleCalcs.ArmorCalc(playerBattler)
			playerBattler.pGuard += playerGuards[0]
			playerBattler.mGuard += playerGuards[1]
			var enemyGuards:Array[int] = BattleCalcs.ArmorCalc(enemyBattler)
			enemyBattler.pGuard += playerGuards[0]
			enemyBattler.mGuard += playerGuards[1]
			
			pass #Pre-Round post-selection actions: Priority + Armor set, Status Effects(exc Decay), Turn Order
		
		BattleSteps.BeforeAll:
			pass #Post-declaration cleanup, Tactics(switchout/flee)
		
		BattleSteps.BeforeFirst:
			var user:BattlerData = currentOrder[0]
			var target:BattlerData = currentOrder[0].currentTarget
			if user.currentTactic != null:
				pass #skip to AfterFirst step
				currentStep = BattleSteps.AfterFirst
				EventBus.emit_signal("BattleStateChanged", currentStep)
				RoundStep()
			if user.currentSpell != null:
				pass #skip to AfterFirst step
				currentStep = BattleSteps.AfterFirst
				EventBus.emit_signal("BattleStateChanged", currentStep)
				RoundStep()
			var attackConditional:bool = user.currentMove.BeforeSkill(self,user,target)
			if attackConditional == false:
				pass #skip attack processing and go to Second steps
			ChangeDistance(user.currentMove.movement + user.currentTheme.movement)
			pass #Pre-attack actions: Attack Announcement, Conditionals, Movement
			currentStep = BattleSteps.DuringFirst
			EventBus.emit_signal("BattleStateChanged", currentStep)
			RoundStep()
		
		BattleSteps.DuringFirst:
			pass #Attack processing: Damage/Status calcs, primary effects, determine death state
		
		BattleSteps.AfterFirst:
			pass #Post-attack processing: Decay/Recoil, Self Death State, Stat Boosts, Heal/Cleanse, World State, Switch-outs
		
		BattleSteps.BeforeSecond:
			pass #Pre-attack actions: Attack Announcement, Conditionals, Movement
		
		BattleSteps.DuringSecond:
			pass #Attack processing: Damage/Status calcs, primary effects, determine death state
		
		BattleSteps.AfterSecond:
			pass #Post-attack processing: Decay/Recoil, Death State, Stat Boosts, Heal/Cleanse, World State, Switch-outs
		
		BattleSteps.Cleanup:
			pass #Soft reset battlers, prompt switch-ins if dead
		
		BattleSteps.Recycle:
			pass #Reset battle system values for next turn

func ChangeDistance(amount:int):
	amount = clampi(amount,-Enums.Ranges.size(),Enums.Ranges.size())
	var tally:int = abs(amount)
	for step in range(amount):
		if tally == 0:
			break
		if amount > 0:
			currentRange = clampi(currentRange+1, 0, Enums.Ranges.size())
			tally -= 1
		elif amount < 0:
			currentRange = clampi(currentRange-1, 0, Enums.Ranges.size())
			tally -= 1
	#send move sprite/stage signal TEMP (note for future, use array of bools to check layers up or down)
	pass

func SwitchOut(battler:BattlerData, targetFaeble:Faeble):
	battler.ChangeBattler(targetFaeble)
	#Send visual switchout signals to UI and sprite

func DefeatBattler(player:bool):
	pass #Hide health UI, animate death, prompt battler swap

func NextBattler(player:bool):
	pass #Show health UI, animate entry, process ChangeBattler


func _on_button_button_down() -> void: #TEMP
	currentStep += 1
	if currentStep >= 12:
		currentStep = 0
	EventBus.emit_signal("BattleStateChanged", currentStep)
	pass # Replace with function body.
