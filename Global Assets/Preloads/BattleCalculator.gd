extends Node

@export_category("Damage Calculation Values")
@export var PSI:float = 2.5 #Per Stage Increase
@export var LT:int = 2 #Low Difference Threshold
@export var HT:int = 4 #High Difference Threshold
@export var LB:int = 0.5 #Bonus Damage Per Level
@export var grazeDebuff:float = 0.5 #Divisor on miss
@export var maxStages:int = 2

@export var statusDecrease:float = 0.5

@export var guardTiers:Array[int] = [3,7,11,15,19,24]
@export var guardReduction:Array[int] = [1,2,3,4,5,6]
@export var doubleGuardBonus:int = 1 #how many defense tiers you raise for double guarding

@export var tierDamage:Array[int] = [4,8,12]
@export var tierCaps:Array[int] = [2,4,6]
@export var WTB:Array[float] = [1, 1.5, 2] #Bonus for Matchup Weakness
@export var SCTB:Array[float] = [0.5, 1, 1] #Bonus for School Affinity
@export var LTTB:Array[float] = [0.5, 1, 1] #Bonus for Low Difference Threshold
@export var HTTB:Array[float] = [1, 1.5, 2] #Bonus for High Difference Threshold

@export var tierStatus:Array[int] = [2,4]
@export var tierStatusCaps:Array[int] = [1,2]
@export var WstTB:Array[float] = [0.5,1] #Bonus for Matchup Weakness
@export var SCstTB:Array[float] = [0.5, 0.5] #Bonus for School Affinity
@export var LTstTB:Array[float] = [0.5, 1] #Bonus for Low Difference Threshold
@export var HTstTB:Array[float] = [1, 1.5] #Bonus for High Difference Threshold



func DamageCalc(user:BattlerData, target:BattlerData, currentRange:int) -> int:
	var attacker:Faeble = user.instance.duplicate()
	var defender:Faeble = target.instance.duplicate()
	var attackerStat:int
	var defenderStat:int
	var attackerStages:Array[int] = user.buffStages.duplicate()
	var defenderStages:Array[int] = target.buffStages.duplicate()
	var attack:Skill = user.currentMove
	var tier:int = attack.damageTier - 1
	var damage:int = tierDamage[tier]
	
	#Affinity damage declaration
	if attack.school == attacker.affinity:
		damage += SCTB[tier]
	var moveSchool:School
	if attack.school.typeIndex == Enums.Schools.Catalyst:
		moveSchool = attacker.affinity
	else:
		moveSchool = attack.school
	
	#Stat Difference damage declaration
	var powerMod:int
	if attack.magical == false:
		attackerStat = attacker.brawn + ceili(attackerStages[Enums.Attributes.Brawn] * PSI)
		if user.status == Enums.Status.Break:
			attackerStat = ceili(attackerStat * statusDecrease)
		defenderStat = defender.vigor + ceili(defenderStages[Enums.Attributes.Vigor] * PSI)
		if user.status == Enums.Status.Decay:
			defenderStat = ceili(defenderStat * statusDecrease)
	elif attack.magical == true:
		attackerStat = attacker.wit + ceili(attackerStages[Enums.Attributes.Wit] * PSI)
		if user.status == Enums.Status.Fixate:
			attackerStat = ceili(attackerStat * statusDecrease)
		defenderStat = defender.ambition + ceili(defenderStages[Enums.Attributes.Ambition] * PSI)
		if user.status == Enums.Status.Silence:
			defenderStat = ceili(defenderStat * statusDecrease)
	
	if attackerStat >= defenderStat + HT: powerMod += HTTB[tier]
	elif attackerStat >= defenderStat + LT: powerMod += LTTB[tier]
	elif defenderStat >= attackerStat + LT: powerMod -= LTTB[tier]
	elif defenderStat >= attackerStat + HT: powerMod -= HTTB[tier]
	damage += powerMod
	
	#Type Matchup damage declaration
	var matchupMod:int = MatchupCalc(defender, moveSchool)
	damage += (matchupMod * WTB[tier])
	
	#Tier Cap clamping + Armor
	var guard:int
	if attack.magical:
		guard = target.mGuard
	else:
		guard = target.pGuard
	guard = clampi(guard, 0, tierCaps[tier])
	var minCap:int = tierDamage[tier]-tierCaps[tier]
	var maxCap:int = tierDamage[tier]+clampi(tierCaps[tier]-guard,0,tierCaps[tier])
	damage = clamp(damage, minCap, maxCap)
	
	#Level Bonus damage declaration
	if attacker.chapter > defender.chapter:
		damage += ((attacker.chapter - defender.chapter) * LB)
	elif attacker.chapter < defender.chapter:
		damage += ((defender.chapter - attacker.chapter) * LB)
	#Range Handling goes here, TEMP
	var modRange:Array[bool] = attack.rangeBands.duplicate()
	var rangeIndex:int = 0
	for band in user.currentTheme.rangeBands:
		if band == true:
			modRange[rangeIndex] = true
		rangeIndex += 1
	if user.currentTheme.rangeReplace:
		modRange = user.currentTheme.rangeBands
	if modRange[currentRange] == false:
		damage *= grazeDebuff
	
	damage = floori(damage + user.currentTheme.damageBoost)
	return damage

func StatusCalc(user:BattlerData, target:BattlerData) -> int:
	var attacker:Faeble = user.instance.duplicate()
	var defender:Faeble = target.instance.duplicate()
	var attack:Skill = user.currentMove
	var attackerStat:int = attacker.prowess
	var defenderStat:int = defender.resolve
	var statusType:Enums.Status = attack.statusType
	var tier:int = attack.statusTier - 1
	var buildup:int = tierStatus[tier]
	
	#Affinity damage declaration
	if attack.school == attacker.affinity:
		buildup += SCstTB[tier]
	
	#Stat Difference damage declaration
	if attackerStat >= defenderStat + HT: buildup += HTstTB[tier]
	elif attackerStat >= defenderStat + LT: buildup += LTstTB[tier]
	elif defenderStat >= attackerStat + LT: buildup -= LTstTB[tier]
	elif defenderStat >= attackerStat + HT: buildup -= HTstTB[tier]
	
	#Type Matchup damage declaration
	var matchupMod:int = MatchupCalc(defender, attack.school)
	buildup += (matchupMod * WstTB[tier])
	
	#Tier Cap clamping
	buildup = clamp(buildup, tierStatus[tier]-tierStatusCaps[tier], tierStatus[tier]+tierStatusCaps[tier])
	buildup = floori(buildup + user.currentTheme.buildupBoost)
	return buildup

func MatchupCalc(target:Faeble, attackingType:School) -> int: #Returns multiplier int
	var mod:int #Output
	var damageMultiplier:int = 1 #Running tally of adjustment multiplier (affects variable below)
	var damageAdjustment:int = 0 #Running tally of resistance "stage"
	# Import types for defenses
	var firstType:Domain = target.firstDomain 
	var secondType:Domain = target.secondDomain
	var signatureType:School = target.affinity
	
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
	
	mod = damageAdjustment * damageMultiplier
	return mod

func SpeedCalc(playerBattler:BattlerData, enemyBattler:BattlerData) -> Array[int]:
	var speedDif:int
	var pSpeed:int = playerBattler.instance.grace
	pSpeed +=  playerBattler.buffStages[Enums.Attributes.Grace] * PSI
	if playerBattler.status == Enums.Status.Slow:
		pSpeed = ceili(pSpeed * statusDecrease)
	var eSpeed:int = enemyBattler.instance.grace
	eSpeed +=  enemyBattler.buffStages[Enums.Attributes.Grace] * PSI
	if enemyBattler.status == Enums.Status.Slow:
		eSpeed = ceili(eSpeed * statusDecrease)
	if pSpeed >= eSpeed + HT: speedDif=2
	elif pSpeed >= eSpeed + LT: speedDif=1
	elif eSpeed >= pSpeed + LT: speedDif=-1
	elif eSpeed >= pSpeed + HT: speedDif=-2
	else: speedDif=0
	
	var pPriority:int
	if playerBattler.currentMove != null:
		pPriority = playerBattler.currentMove.priority
		if playerBattler.currentTheme != null:
			pPriority += playerBattler.currentTheme.priority
		if playerBattler.status == Enums.Status.Slow:
			pPriority = 0
	elif playerBattler.currentSpell != null:
		pPriority = playerBattler.currentSpell.priority + 10
	elif playerBattler.currentTactic != null:
		pPriority = 20
	if speedDif > 0: pPriority += abs(speedDif)
	
	var ePriority:int
	if enemyBattler.currentMove != null:
		ePriority = enemyBattler.currentMove.priority
		if enemyBattler.currentTheme != null:
			ePriority += enemyBattler.currentTheme.priority
		if enemyBattler.status == Enums.Status.Slow:
			ePriority = 0
	elif enemyBattler.currentSpell != null:
		ePriority = enemyBattler.currentSpell.priority + 10
	elif enemyBattler.currentTactic != null:
		ePriority = 20
	if speedDif < 0: ePriority += abs(speedDif)
	
	return [pPriority, ePriority]

func TurnCalc(playerBattler:BattlerData, enemyBattler:BattlerData) -> Array[BattlerData]:
	var pPriority:int = playerBattler.priority
	var pSpeed:int = playerBattler.instance.grace
	var ePriority:int = enemyBattler.priority
	var eSpeed:int = enemyBattler.instance.grace
	var playerFirst:bool = false
	if pPriority > ePriority: playerFirst = true
	elif pPriority < ePriority: playerFirst = false
	else:
		if pSpeed > eSpeed: playerFirst = true
		elif eSpeed > pSpeed: playerFirst = false
		else:
			var RNG = RandomNumberGenerator.new()
			RNG.randomize()
			var coinflip = RNG.randi_range(0, 1)
			if coinflip: playerFirst = true
			else: playerFirst = false
	if playerFirst: return [playerBattler, enemyBattler]
	else: return [enemyBattler, playerBattler]

func ArmorCalc(user:BattlerData) -> Array[int]:
	var i:int = 0
	var pGuard:int
	var mGuard:int
	if user.status == Enums.Status.Break:
		return [0,0]
	for tier in guardTiers:
		if user.instance.vigor <= tier:
			break
		i += 1
	if user.currentMove.pGuarding or user.currentTheme.pGuarding:
		pGuard = guardReduction[i]
	if user.currentMove.pGuarding and user.currentTheme.pGuarding:
		pGuard = guardReduction[clampi(i+doubleGuardBonus,0,5)]
	i = 0
	
	for tier in guardTiers:
		if user.instance.ambition <= tier:
			break
		i += 1
	if user.currentMove.mGuarding or user.currentTheme.mGuarding:
		mGuard = guardReduction[i]
	if user.currentMove.mGuarding and user.currentTheme.mGuarding:
		mGuard = guardReduction[clampi(i+doubleGuardBonus,0,5)]
	i = 0
	return [pGuard, mGuard]
