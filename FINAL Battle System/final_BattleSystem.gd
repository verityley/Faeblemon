extends Node
class_name BattleSystemFINAL

@export var playerBattler:BattlerData
@export var enemyBattler:BattlerData

var playerSent:bool
var enemySent:bool

@export var currentRange:Enums.Ranges = Enums.Ranges.Near
@export var currentOrder:Array[BattlerData]
@export var currentAura:Aura
@export var currentStep:BattleSteps

var auraValue #Use this to track any across-step values like Pact aura damage taken, etc

@export_category("Debug")
@export var playerWitch:Witch
@export var enemyWitch:Witch

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
	AfterAll,
	Recycle
}

enum MenuActions {
	Back=-1,
	Attack,
	Witch,
	Tactics
}

func _ready():
	var i:int = 0
	for faeble in playerWitch.party:
		if faeble != null:
			playerWitch.party[i] = FaebleCreation.CreateFaeble(faeble)
		i += 1
	i = 0
	for faeble in enemyWitch.party:
		if faeble != null:
			enemyWitch.party[i] = FaebleCreation.CreateFaeble(faeble)
		i += 1
	SetupBattle(playerWitch, enemyWitch)

func SetupBattle(pWitch:Witch, eWitch:Witch):
	playerBattler.witchInstance = pWitch
	enemyBattler.witchInstance = eWitch
	for p in pWitch.party:
		if p != null:
			playerBattler.faebleTeam.append(p.duplicate())
	playerBattler.ChangeBattler(playerBattler.faebleTeam[0])
	EventBus.emit_signal("FaebleSwitched", playerBattler)
	for e in eWitch.party:
		if e != null:
			enemyBattler.faebleTeam.append(e.duplicate())
	enemyBattler.ChangeBattler(enemyBattler.faebleTeam[0])
	EventBus.emit_signal("FaebleSwitched", enemyBattler)
	currentRange = Enums.Ranges.Near
	EventBus.emit_signal("FaebleMoved", currentRange)
	currentStep = BattleSteps.Startup
	EventBus.emit_signal("BattleStateChanged", currentStep)
	EventBus.emit_signal("BattleStart")
	RoundStep()


func Selection(battler:BattlerData, action:MenuActions, option:int=-1, detail:int=-1):
	if action == MenuActions.Back:
		return
	
	if battler == playerBattler: playerSent = true
	elif battler == enemyBattler: enemySent = true
	#prints(playerSent,enemySent)
	
	match action:
		MenuActions.Attack:
			battler.currentSpell = battler.instance.assignedSpells[option] #Assign Move
			if detail == 3: #Assign own Theme if option 4 picked
				battler.currentTheme = battler.instance.setTheme
			elif detail != -1: #Otherwise select from Witch Themes
				battler.currentTheme = battler.witchInstance.assignedThemes[detail]
			#Determine other default target
			if battler == playerBattler: battler.currentTarget = enemyBattler
			elif battler == enemyBattler: battler.currentTarget = playerBattler
			
			prints(battler.name,battler.currentSpell.name,battler.currentTheme.name)
			RoundStep()
		
		MenuActions.Witch:
			battler.currentWitchSpell = battler.witchInstance.assignedSpells[option] #Assign Spell
			if detail != -1: #If no detail, no extra Faeble target
				battler.currentTarget = battler
				battler.currentFaeble = battler.faebleTeam[detail] #I sort of get what this was? but really needs work
			else: #Determine other default target
				battler.currentTarget = battler
			RoundStep()
		
		MenuActions.Tactics:
			battler.currentTactic = option
			if option == 0: #Switch
				battler.currentFaeble = battler.faebleTeam[detail]
				battler.switching = true
			elif option == 1: #Flee
				pass
			RoundStep()

func RoundStep():
	await get_tree().create_timer(0.2).timeout
	match currentStep:
		BattleSteps.Startup:
			currentStep = BattleSteps.ActionSelect
			EventBus.emit_signal("BattleStateChanged", currentStep)
			RoundStep()
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
			var priorities:Array[int] = BattleCalcs.SpeedCalc(playerBattler,enemyBattler,currentAura)
			playerBattler.priority += priorities[0]
			enemyBattler.priority += priorities[1]
			currentOrder = BattleCalcs.TurnCalc(playerBattler,enemyBattler)
			if currentAura != null:
				if currentAura.priorityFlip:
					currentOrder.reverse()
			print(currentOrder)
			
			#Determine Armor of combatants
			var playerGuards:Array[int] = BattleCalcs.ArmorCalc(playerBattler)
			playerBattler.pGuard += playerGuards[0]
			playerBattler.mGuard += playerGuards[1]
			var enemyGuards:Array[int] = BattleCalcs.ArmorCalc(enemyBattler)
			enemyBattler.pGuard += playerGuards[0]
			enemyBattler.mGuard += playerGuards[1]
			
			currentStep = BattleSteps.BeforeAll
			EventBus.emit_signal("BattleStateChanged", currentStep)
			RoundStep()
			pass #Pre-Round post-selection actions: Priority + Armor set, Status Effects(exc Decay), Turn Order
		
		BattleSteps.BeforeAll:
			if currentAura != null:
				currentAura.AtBattleStep(currentStep, self)
			currentStep = BattleSteps.BeforeFirst
			EventBus.emit_signal("BattleStateChanged", currentStep)
			RoundStep()
			pass #Post-declaration cleanup, Tactics(switchout/flee)
		
		BattleSteps.BeforeFirst:
			var user:BattlerData = currentOrder[0]
			var target:BattlerData = currentOrder[0].currentTarget
			if user.currentTactic != null:
				pass #skip to AfterFirst step
				currentStep = BattleSteps.AfterFirst
				EventBus.emit_signal("BattleStateChanged", currentStep)
				RoundStep()
			if user.currentWitchSpell != null:
				pass #skip to AfterFirst step
				currentStep = BattleSteps.AfterFirst
				EventBus.emit_signal("BattleStateChanged", currentStep)
				RoundStep()
			if user.currentSpell != null:
				var attackConditional:bool = user.currentSpell.BeforeSpell(self,user,target)
				if attackConditional == false:
					pass #skip attack processing and go to Second steps
			ChangeDistance(user.currentSpell.movement + user.currentTheme.movement)
			pass #Pre-attack actions: Attack Announcement, Conditionals, Movement
			
			currentStep = BattleSteps.DuringFirst
			EventBus.emit_signal("BattleStateChanged", currentStep)
			RoundStep()
		
		BattleSteps.DuringFirst:
			var user:BattlerData = currentOrder[0]
			var target:BattlerData = currentOrder[0].currentTarget
			if user.currentSpell != null:
				user.currentSpell.ExecuteSpell(user, target, currentRange)
			
			currentStep = BattleSteps.AfterFirst
			EventBus.emit_signal("BattleStateChanged", currentStep)
			RoundStep()
			pass #Attack processing: Damage/Status calcs, primary effects, determine death state
		
		BattleSteps.AfterFirst:
			var user:BattlerData = currentOrder[0]
			var target:BattlerData = currentOrder[0].currentTarget
			if user.currentSpell != null:
				user.currentSpell.AfterSpell(user, target)
			
			if user.status == Enums.Status.Decay:
				var damage:int = ceili(float(user.instance.maxHP)*BattleCalcs.decayPercent)
				user.health = clampi(user.health-damage, 0, user.instance.maxHP)
				user.damageTaken += damage
				print("Decay Tick Damage: ", damage)
				EventBus.emit_signal("HealthChanged", user)
			
			currentStep = BattleSteps.BeforeSecond
			EventBus.emit_signal("BattleStateChanged", currentStep)
			RoundStep()
			pass #Post-attack processing: Decay/Recoil, Stat Boosts, Heal/Cleanse, World State, Switch-outs
		
		BattleSteps.BeforeSecond:
			var user:BattlerData = currentOrder[1]
			var target:BattlerData = currentOrder[1].currentTarget
			if user.currentTactic != null:
				pass #skip to AfterFirst step
				currentStep = BattleSteps.AfterSecond
				EventBus.emit_signal("BattleStateChanged", currentStep)
				RoundStep()
			if user.currentWitchSpell != null:
				pass #skip to AfterFirst step
				currentStep = BattleSteps.AfterSecond
				EventBus.emit_signal("BattleStateChanged", currentStep)
				RoundStep()
			if user.currentSpell != null:
				var attackConditional:bool = user.currentSpell.BeforeSpell(self,user,target)
				if attackConditional == false:
					pass #skip attack processing and go to Second steps
			ChangeDistance(user.currentSpell.movement + user.currentTheme.movement)
			
			currentStep = BattleSteps.DuringSecond
			EventBus.emit_signal("BattleStateChanged", currentStep)
			RoundStep()
			pass #Pre-attack actions: Attack Announcement, Conditionals, Movement
		
		BattleSteps.DuringSecond:
			var user:BattlerData = currentOrder[1]
			var target:BattlerData = currentOrder[1].currentTarget
			if user.currentSpell != null:
				user.currentSpell.ExecuteSpell(user, target, currentRange)
			
			currentStep = BattleSteps.AfterSecond
			EventBus.emit_signal("BattleStateChanged", currentStep)
			RoundStep()
			pass #Attack processing: Damage/Status calcs, primary effects, determine death state
		
		BattleSteps.AfterSecond:
			var user:BattlerData = currentOrder[1]
			var target:BattlerData = currentOrder[1].currentTarget
			if user.currentSpell != null:
				user.currentSpell.AfterSpell(user, target)
			
			if user.status == Enums.Status.Decay:
				var damage:int = ceili(float(user.instance.maxHP)*BattleCalcs.decayPercent)
				user.health = clampi(user.health-damage, 0, user.instance.maxHP)
				user.damageTaken += damage
				print("Decay Tick Damage: ", damage)
				EventBus.emit_signal("HealthChanged", user)
			
			currentStep = BattleSteps.AfterAll
			EventBus.emit_signal("BattleStateChanged", currentStep)
			RoundStep()
			pass #Post-attack processing: Decay/Recoil, Stat Boosts, Heal/Cleanse, Aura State, Switch-outs
		
		BattleSteps.AfterAll:
			if currentAura != null:
				currentAura.AtBattleStep(currentStep, self)
			
			playerBattler.ResetBattler()
			enemyBattler.ResetBattler()
			
			currentStep = BattleSteps.Recycle
			EventBus.emit_signal("BattleStateChanged", currentStep)
			RoundStep()
			pass #Soft reset battlers, Check Death States, prompt switch-ins if dead
		
		BattleSteps.Recycle:
			currentOrder.clear()
			playerSent = false
			enemySent = false
			
			currentStep = BattleSteps.Startup
			EventBus.emit_signal("BattleStateChanged", currentStep)
			RoundStep()
			pass #Reset battle system values for next turn

func ChangeDistance(amount:int):
	var rangeBands:int = Enums.Ranges.size()-1
	amount = clampi(amount,-rangeBands,rangeBands)
	#prints(rangeBands, amount)
	for step in range(abs(amount)):
		if amount > 0:
			currentRange = clampi(currentRange+1, 0, rangeBands)
		elif amount < 0:
			currentRange = clampi(currentRange-1, 0, rangeBands)
	#prints("Moving to:", Enums.Ranges.keys()[currentRange],currentRange, amount)
	EventBus.emit_signal("FaebleMoved", currentRange)
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
	RoundStep()
	pass # Replace with function body.
