extends Node

@export_category("Damage Calculation Values")
@export var PSI:float = 2.5 #Per Stage Increase
@export var LT:int = 2 #Low Difference Threshold
@export var HT:int = 4 #High Difference Threshold
@export var LB:int = 0.5 #Bonus Damage Per Level
@export var grazeDebuff:float = 2.0 #Divisor on miss
@export var maxStages:int = 2

@export var statusDecrease:float = 0.5

@export var guardTiers:Array[int] = [3,7,11,15,19,24] #Defensive stat needed to gain next guard reduction
@export var guardReduction:Array[int] = [1,2,3,4,5,6] #Guard reduction reduces tier cap for damage
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
@export var decayPercent:float = 0.2


func DamageCalc(attack:Spell, user:BattlerData, target:BattlerData, currentRange:int, aura:Aura=null) -> Dictionary:
	var attacker:Faeble = user.instance.duplicate()
	var defender:Faeble = target.instance.duplicate()
	var attackerStat:int
	var defenderStat:int
	var attackerStages:Array[int] = user.buffStages.duplicate()
	var defenderStages:Array[int] = target.buffStages.duplicate()
	var tier:int = attack.damageTier - 1
	var results:Dictionary = {
		"Damage": 0,
		"MatchupMult": 0, #Positive if effective, negative if weakness
		"Guarded": false,
		"Missed": false,
		"AuraEffect": false
	}
	
	if tier == -1:
		print("Error! Not a damaging move!")
		return results
	var damage:float = tierDamage[tier]
	
	#Affinity damage declaration
	if attack.school == attacker.affinity:
		damage += SCTB[tier]
		print("Attack has Affinity Bonus: +",SCTB[tier],", Damage: ", damage)
	var moveSchool:School
	if attack.school.typeIndex == Enums.Schools.Catalyst:
		moveSchool = attacker.affinity
	else:
		moveSchool = attack.school
	
	#Stat Difference damage declaration
	var powerMod:float = 0
	if attack.magical == false:
		attackerStat = attacker.brawn + ceili(attackerStages[Enums.Attributes.Brawn] * PSI)
		if user.buildupTarget == Enums.Status.Break and user.buildup >= floori(user.instance.maxBuildup/2):
			attackerStat = ceili(attackerStat * statusDecrease)
			print("Attacker has Break Status above half, halving Brawn.")
		defenderStat = defender.vigor + ceili(defenderStages[Enums.Attributes.Vigor] * PSI)
		if target.buildupTarget == Enums.Status.Decay and target.buildup >= floori(target.instance.maxBuildup/2):
			defenderStat = ceili(defenderStat * statusDecrease)
			print("Defender has Decay Status above half, halving Vigor.")
	elif attack.magical == true:
		attackerStat = attacker.wit + ceili(attackerStages[Enums.Attributes.Wit] * PSI)
		if user.buildupTarget == Enums.Status.Fixate and user.buildup >= floori(user.instance.maxBuildup/2):
			attackerStat = ceili(attackerStat * statusDecrease)
			print("Attacker has Fixate Status above half, halving Wit.")
		defenderStat = defender.ambition + ceili(defenderStages[Enums.Attributes.Ambition] * PSI)
		if target.buildupTarget == Enums.Status.Silence and target.buildup >= floori(target.instance.maxBuildup/2):
			defenderStat = ceili(defenderStat * statusDecrease)
			print("Defender has Silence Status above half, halving Ambition.")
	
	if attackerStat >= defenderStat + HT:
		powerMod += HTTB[tier]
		print("Attack has High Difference Bonus: +",HTTB[tier],", Damage: ", damage+powerMod)
	elif attackerStat >= defenderStat + LT: 
		powerMod += LTTB[tier]
		print("Attack has Low Difference Bonus: +",LTTB[tier],", Damage: ", damage+powerMod)
	elif defenderStat >= attackerStat + LT: 
		powerMod -= LTTB[tier]
		print("Attack has Low Difference Penalty: -",LTTB[tier],", Damage: ", damage+powerMod)
	elif defenderStat >= attackerStat + HT: 
		powerMod -= HTTB[tier]
		print("Attack has High Difference Penalty: -",HTTB[tier],", Damage: ", damage+powerMod)
	damage += powerMod
	
	#Type Matchup damage declaration
	var matchupMod:float = MatchupCalc(defender, moveSchool)
	damage += (matchupMod * WTB[tier])
	if matchupMod > 0:
		print("Attack has Weakness Bonus: +",WTB[tier]," x ",matchupMod,", Damage: ", damage)
	elif matchupMod < 0:
		print("Attack has Resistance Penalty: -",WTB[tier]," x ",matchupMod,", Damage: ", damage)
	results["MatchupMult"] = matchupMod
	
	#Range Handling goes here
	if RangeCalc(attack,user,aura)[currentRange] == false:
		damage -= tierCaps[tier]
		print("Attack has Miss Penalty: -",tierCaps[tier],", Damage: ", damage)
		results["Missed"] = true
	
	#Theme Handling
	if user.currentTheme.damageBoost != 0:
		damage += user.currentTheme.damageBoost
		print("Attack has Theme Bonus: +",user.currentTheme.damageBoost,", Damage: ", damage)
	
	#Aura damage handling
	if aura != null:
		if aura.LinkCheck(user) and aura.damageMod != 0:
			var auraMod:float
			if aura.tiered:
				auraMod = aura.tieredMod[tier]
			else:
				auraMod = aura.damageMod
			if aura.doubleLinked and aura.LinkCheck(user,false):
					auraMod *= 2
			if aura.additive: damage += auraMod
			elif aura.subtractive: damage -= auraMod
			elif aura.multiplicative: damage *= auraMod
			elif aura.replacement: damage = auraMod
			print("Attack has Aura Effect: ",auraMod,", Damage: ", damage)
			results["AuraEffect"] = true
	
	#Tier Cap clamping + Armor
	var guard:float
	if attack.magical:
		guard = target.mGuard
	else:
		guard = target.pGuard
	guard = clampi(guard, 0, tierCaps[tier])
	var minCap:int = tierDamage[tier]-tierCaps[tier]
	var maxCap:int = tierDamage[tier]+clampi(tierCaps[tier]-guard,minCap,tierCaps[tier])
	if guard > 0:
		print("Attack hit Guard, maximum damage capped at: ",maxCap)
		results["Guarded"] = false
	damage = clamp(damage, minCap, maxCap)
	
	#Level Bonus damage declaration
	if attacker.chapter > defender.chapter:
		damage += ((attacker.chapter - defender.chapter) * LB)
		print("Attack has Level Bonus: +",((attacker.chapter - defender.chapter) * LB),", Damage: ", damage)
	elif attacker.chapter < defender.chapter:
		damage += ((defender.chapter - attacker.chapter) * LB)
		print("Attack has Level Penalty: +",((defender.chapter - attacker.chapter) * LB),", Damage: ", damage)
	
	
	print("Final Damage: ", damage)
	results["Damage"] = int(damage)
	return results

func StatusCalc(attack:Spell, user:BattlerData, target:BattlerData, currentRange:int,aura:Aura=null) -> Dictionary:
	var attacker:Faeble = user.instance.duplicate()
	var defender:Faeble = target.instance.duplicate()
	var attackerStat:int = attacker.prowess
	var defenderStat:int = defender.resolve
	var statusType:Enums.Status = attack.statusType
	var tier:int = attack.statusTier - 1
	var buildup:float = tierStatus[tier]
	var results:Dictionary = {
		"Buildup": 0, #How much status buildup to deal
		"MatchupMult": 0, #Positive if effective, negative if weakness
		"Missed": false,
		"AuraEffect": false
	}
	
	#Affinity damage declaration
	if attack.school == attacker.affinity:
		buildup += SCstTB[tier]
		print("Status Attack has Affinity Bonus: +",SCstTB[tier],", Buildup: ", buildup)
	
	#Stat Difference damage declaration
	prints(attackerStat,"vs.",defenderStat)
	if attackerStat >= defenderStat + HT:
		buildup += HTstTB[tier]
		print("Status Attack has High Difference Bonus: +",HTstTB[tier],", Buildup: ", buildup)
	elif attackerStat >= defenderStat + LT:
		buildup += LTstTB[tier]
		print("Status Attack has Low Difference Bonus: +",LTstTB[tier],", Buildup: ", buildup)
	elif defenderStat >= attackerStat + LT:
		buildup -= LTstTB[tier]
		print("Status Attack has Low Difference Penalty: -",LTstTB[tier],", Buildup: ", buildup)
	elif defenderStat >= attackerStat + HT:
		buildup -= HTstTB[tier]
		print("Status Attack has High Difference Penalty: -",HTstTB[tier],", Buildup: ", buildup)
	
	#Type Matchup damage declaration
	var matchupMod:float = MatchupCalc(defender, attack.school)
	buildup += (matchupMod * WstTB[tier])
	if matchupMod > 0:
		print("Attack has Weakness Bonus: +",WstTB[tier]," x ",matchupMod,", Buildup: ", buildup)
	elif matchupMod < 0:
		print("Attack has Resistance Penalty: -",WstTB[tier]," x ",matchupMod,", Buildup: ", buildup)
	results["MatchupMult"] = matchupMod
	
	#Range Handling goes here
	if RangeCalc(attack,user,aura)[currentRange] == false:
		buildup -= tierStatusCaps[tier]
		print("Status Attack has Miss Penalty: -",tierStatusCaps[tier],", Buildup: ", buildup)
		results["Missed"] = true
	
	#Theme Handling
	if user.currentTheme.buildupBoost != 0:
		buildup = floori(buildup + user.currentTheme.buildupBoost)
		print("Status Attack has Theme Bonus: +",user.currentTheme.buildupBoost,", Buildup: ", buildup)
	
	#Aura damage handling
	if aura != null:
		if aura.LinkCheck(user) and aura.buildupMod != 0:
			if aura.matchStatus == false or (aura.matchStatus == true and statusType == aura.status):
				var auraMod:float
				if aura.tiered:
					auraMod = aura.tieredMod[tier]
				else:
					auraMod = aura.buildupMod
				if aura.doubleLinked and aura.LinkCheck(user,false):
					auraMod *= 2
				if aura.additive: buildup += auraMod
				elif aura.subtractive: buildup -= auraMod
				elif aura.multiplicative: buildup *= auraMod
				elif aura.replacement: buildup = auraMod
				print("Status Attack has Aura Effect: ",auraMod,", Buildup: ", buildup)
				results["AuraEffect"] = true
	
	#Tier Cap clamping
	buildup = clamp(buildup, tierStatus[tier]-tierStatusCaps[tier], tierStatus[tier]+tierStatusCaps[tier])
	
	
	print("Final Buildup: ",buildup)
	results["Buildup"] = int(buildup)
	return results

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

func RangeCalc(attack:Spell,user:BattlerData,aura:Aura=null) -> Array[bool]:
		#Range Handling goes here
	var modRange:Array[bool] = attack.rangeBands.duplicate()
	var rangeIndex:int = 0
	for band in user.currentTheme.rangeBands:
		if band == true:
			modRange[rangeIndex] = true
		rangeIndex += 1
	if user.currentTheme.rangeReplace:
		modRange = user.currentTheme.rangeBands
	rangeIndex = 0
	if aura != null:
		if aura.LinkCheck(user):
			for band in aura.rangeMod:
				if aura.additive and band == true:
					modRange[rangeIndex] = true
				elif aura.subtractive and band == false:
					modRange[rangeIndex] = false
				elif aura.replacement:
					modRange[rangeIndex] = band
	return modRange


func SpeedCalc(playerBattler:BattlerData, enemyBattler:BattlerData,aura:Aura=null) -> Array[int]:
	var speedDif:int
	var pSpeed:int = playerBattler.instance.grace
	pSpeed +=  playerBattler.buffStages[Enums.Attributes.Grace] * PSI
	if playerBattler.buildupTarget == Enums.Status.Slow:
		if playerBattler.buildup >= playerBattler.instance.maxBuildup/2:#Half of Heart stat might be TEMP
			pSpeed = ceili(pSpeed * statusDecrease)
			print("Player has Slow Status above half, halving Grace.")
	var eSpeed:int = enemyBattler.instance.grace
	eSpeed +=  enemyBattler.buffStages[Enums.Attributes.Grace] * PSI
	if enemyBattler.buildupTarget == Enums.Status.Slow:
		if enemyBattler.buildup >= enemyBattler.instance.maxBuildup/2:#Half of Heart stat might be TEMP
			eSpeed = ceili(eSpeed * statusDecrease)
			print("Enemy has Slow Status above half, halving Grace.")
	if pSpeed >= eSpeed + HT: speedDif=2
	elif pSpeed >= eSpeed + LT: speedDif=1
	elif eSpeed >= pSpeed + LT: speedDif=-1
	elif eSpeed >= pSpeed + HT: speedDif=-2
	else: speedDif=0
	
	var pPriority:int
	if playerBattler.currentSpell != null:
		pPriority = playerBattler.currentSpell.priority
		if playerBattler.currentTheme != null:
			pPriority += playerBattler.currentTheme.priority
		if playerBattler.status == Enums.Status.Slow:
			pPriority = 0
	elif playerBattler.currentWitchSpell != null:
		pPriority = playerBattler.currentWitchSpell.priority + 10
	elif playerBattler.currentTactic != null:
		pPriority = 20
	if speedDif > 0: pPriority += abs(speedDif)
	
	if aura != null:
		if aura.LinkCheck(playerBattler):
			var auraMod:int = aura.priorityMod
			if aura.doubleLinked and aura.LinkCheck(playerBattler,false):
				auraMod *= 2
			if aura.additive: pPriority += auraMod
			elif aura.subtractive: pPriority -= auraMod
			elif aura.multiplicative: pPriority *= auraMod
			elif aura.replacement: pPriority = auraMod
			print("Player has Aura Effect: ",auraMod)
	
	var ePriority:int
	if enemyBattler.currentSpell != null:
		ePriority = enemyBattler.currentSpell.priority
		if enemyBattler.currentTheme != null:
			ePriority += enemyBattler.currentTheme.priority
		if enemyBattler.status == Enums.Status.Slow:
			ePriority = 0
	elif enemyBattler.currentWitchSpell != null:
		ePriority = enemyBattler.currentWitchSpell.priority + 10
	elif enemyBattler.currentTactic != null:
		ePriority = 20
	if speedDif < 0: ePriority += abs(speedDif)
	
	if aura != null:
		if aura.LinkCheck(enemyBattler):
			var auraMod:int = aura.priorityMod
			if aura.doubleLinked and aura.LinkCheck(enemyBattler,false):
				auraMod *= 2
			if aura.additive: ePriority += auraMod
			elif aura.subtractive: ePriority -= auraMod
			elif aura.multiplicative: ePriority *= auraMod
			elif aura.replacement: ePriority = auraMod
			print("Enemy has Aura Effect: ",auraMod)
	
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

func ArmorCalc(user:BattlerData,aura:Aura=null) -> Array[int]:
	var i:int = 0
	var pGuard:int
	var mGuard:int
	if user.currentSpell == null:
		return [pGuard, mGuard]
	if user.status == Enums.Status.Break:
		return [0,0]
	for tier in guardTiers:
		if user.instance.vigor <= tier:
			break
		i += 1
	if user.currentSpell.pGuarding or user.currentTheme.pGuarding:
		pGuard = guardReduction[i]
	if user.currentSpell.pGuarding and user.currentTheme.pGuarding:
		pGuard = guardReduction[clampi(i+doubleGuardBonus,0,5)]
	if aura != null:
		if aura.pGuarding and aura.LinkCheck(user):
			if aura.additive: pGuard = guardReduction[clampi(i+doubleGuardBonus,0,5)]
			if aura.subtractive: pGuard = guardReduction[clampi(i-doubleGuardBonus,0,5)]
	i = 0
	
	for tier in guardTiers:
		if user.instance.ambition <= tier:
			break
		i += 1
	if user.currentSpell.mGuarding or user.currentTheme.mGuarding:
		mGuard = guardReduction[i]
	if user.currentSpell.mGuarding and user.currentTheme.mGuarding:
		mGuard = guardReduction[clampi(i+doubleGuardBonus,0,5)]
	if aura != null:
		if aura.mGuarding and aura.LinkCheck(user):
			if aura.additive: mGuard = guardReduction[clampi(i+doubleGuardBonus,0,5)]
			if aura.subtractive: mGuard = guardReduction[clampi(i-doubleGuardBonus,0,5)]
	i = 0
	return [pGuard, mGuard]
