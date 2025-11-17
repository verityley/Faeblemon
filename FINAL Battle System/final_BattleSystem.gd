extends Node
class_name BattleSystemFINAL

@export var playerBattler:BattlerData
@export var enemyBattler:BattlerData

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

func RoundStep():
	match currentStep:
		BattleSteps.Startup:
			pass #Start of Turn, pre-selection actions:
		
		BattleSteps.ActionSelect:
			pass #Awaiting selection from both parties, open menu
		
		BattleSteps.RoundStart:
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
			var target:BattlerData = currentOrder[1]
			if user.currentTactic != null:
				pass #skip to AfterFirst step
				currentStep = BattleSteps.AfterFirst
				RoundStep()
			if user.currentSpell != null:
				pass #skip to AfterFirst step
				currentStep = BattleSteps.AfterFirst
				RoundStep()
			var attackConditional:bool = user.currentMove.BeforeSkill(self,user,target)
			if attackConditional == false:
				pass #skip attack processing and go to Second steps
			ChangeDistance(user.currentMove.movement + user.currentTheme.movement)
			pass #Pre-attack actions: Attack Announcement, Conditionals, Movement
			currentStep = BattleSteps.DuringFirst
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

func DefeatBattler(player:bool):
	pass #Hide health UI, animate death, prompt battler swap

func NextBattler(player:bool):
	pass #Show health UI, animate entry, process ChangeBattler
