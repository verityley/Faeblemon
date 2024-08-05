extends Node

@export var limitBreakOdds:int = 800 #These are all "1 out of X", not the percent chance.
@export var shinyOdds:int = 1000
@export var altSchoolOdds:int = 500

@export var healthRatio:int = 4 #Health per point of HRT
@export var initStatRatio:float = 0.6 #How much stats should be reduced by to build up towards
@export var pointsPerLevel:int = 4

@export var rewardRatio:Vector2i = Vector2i(4,2) #Health:Energy
@export var heartRatio:Vector2i = Vector2i(2,1) #Heart:Reward
@export var energyRatio:Vector2i = Vector2i(1,1) #Wit/Brawn:Reward

enum Stats{
	Brawn=0,
	Vigor,
	Wit,
	Ambition,
	Grace,
	Heart
}

func _ready():
	#CreateFaeble(preload("res://Database/Faebles/001Awoolf.tres"), 8)
	
	pass


func CreateFaeble(faebleEntry:Faeble, initLevel:int) -> Faeble:
	var instance:Faeble = faebleEntry.duplicate()
	var learnList:Dictionary = faebleEntry.skillPool.duplicate()
	
	var RNG = RandomNumberGenerator.new()
	RNG.randomize()
	var profRoll:int #This is -2 to 2, or -1 to 1 if first roll is 1
	var profMax:int = 3 #The max in either direction a side can go, total across all stats
	var breakRoll:int = RNG.randi_range(0, limitBreakOdds)
	var statRoll:int #This is 1-7, keyed to each stat
	var shinyRoll:int = RNG.randi_range(0, shinyOdds)
	var schoolRoll:int = RNG.randi_range(0, altSchoolOdds)
	
	#Initialize Proficiency Spread
	var profLow:int = 0
	var profHigh:int = 0
	var attempts:int = 0
	while profLow > -profMax or profHigh < profMax:
		attempts += 1
		if attempts > 15:
			print("Too many attempts, assigning neutral nature.")
			for i in range(instance.profArray.size()):
				instance.profArray[i] = 0
			break
		
		statRoll = RNG.randi_range(0,5)
		if instance.profArray[statRoll] < 0 and profRoll < 0:
			print("Stat already assigned.")
			continue
		elif instance.profArray[statRoll] > 0 and profRoll > 0:
			print("Stat already assigned.")
			continue
		
		if breakRoll != limitBreakOdds:
			prints("Min Roll:", -(profMax + profLow) + 1, "Max Roll:", profMax - profHigh - 1)
			profRoll = clampi(RNG.randi_range(-(profMax + profLow), profMax - profHigh), -profMax+1, profMax-1)
		elif breakRoll == limitBreakOdds:
			prints("Can have Mastery! Min Roll:", -(profMax + profLow), "Max Roll:", profMax - profHigh)
			profRoll = RNG.randi_range(-(profMax + profLow), profMax - profHigh)
		
		print("Rolled: ", profRoll, " on ", statRoll)
		if profRoll == 0:
			print("Rolled zero, retrying.")
			continue
		elif profRoll < 0:
			profLow += profRoll
			print("New Negative Sum: ", profLow)
		elif profRoll > 0:
			profHigh += profRoll
			print("New Positive Sum: ", profHigh)
		
		instance.profArray[statRoll] += profRoll
		print(instance.profArray)
	print("Final: ", instance.profArray)
	#End of Proficiency Init
	
	#Initialization of adjusted stats from entry base
	var statAdjusts:Array[int] = [
		instance.brawn + instance.profArray[Stats.Brawn],
		instance.vigor + instance.profArray[Stats.Vigor],
		instance.wit + instance.profArray[Stats.Wit],
		instance.ambition + instance.profArray[Stats.Ambition],
		instance.grace + instance.profArray[Stats.Grace],
		instance.heart + instance.profArray[Stats.Heart]
	]
	for stat in range(statAdjusts.size()):
		var attribute:int = clampi(statAdjusts[stat], instance.minQuality, instance.maxQuality)
		instance.roomToGrow[stat] = attribute
		#print("Original stat: ", attribute)
		attribute *= initStatRatio
		instance.roomToGrow[stat] -= attribute
		statAdjusts[stat] = attribute
		print("Reduced stat: ", statAdjusts[stat])
		#print("Room to grow: ", instance.roomToGrow[stat])
	
	
	instance.brawn = clampi(statAdjusts[Stats.Brawn], instance.minQuality, instance.maxQuality)
	instance.vigor = clampi(statAdjusts[Stats.Vigor], instance.minQuality, instance.maxQuality)
	instance.wit = clampi(statAdjusts[Stats.Wit], instance.minQuality, instance.maxQuality)
	instance.ambition = clampi(statAdjusts[Stats.Ambition], instance.minQuality, instance.maxQuality)
	instance.grace = clampi(statAdjusts[Stats.Grace], instance.minQuality, instance.maxQuality)
	instance.heart = clampi(statAdjusts[Stats.Heart], instance.minQuality, instance.maxQuality)
	
	#Start of ASI and Level-up reward Assignment
	instance.chapter = initLevel
	prints("Level:", instance.chapter)
	var asiSpread:Array[String]=["Brawn", "Vigor", "Wit", "Ambition", "Grace", "Heart"]
	asiSpread.append(instance.prefPrimary)
	asiSpread.append(instance.prefPrimary)
	asiSpread.append(instance.prefPrimary)
	asiSpread.append(instance.prefSecondary)
	asiSpread.append(instance.prefSecondary)
	for asi in range(instance.chapter - 1):
		var index:int = 0
		var bannedSelects:Array[int] = []
		while index < pointsPerLevel:
			var attribute:String
			var selection:int = RNG.randi_range(0,asiSpread.size()-1)
			attribute = asiSpread[selection]
			match attribute:
				"Brawn":
					selection = 0
				"Vigor":
					selection = 1
				"Wit":
					selection = 2
				"Ambition":
					selection = 3
				"Grace":
					selection = 4
				"Heart":
					selection = 5
			if instance.roomToGrow[selection] <= 0:
				continue
			if bannedSelects.has(selection):
				print(attribute, " has already maxed out this level, skipping.")
				continue
			print("Improving ", attribute)
			instance.statImprovements[selection] += 1
			prints(attribute, "is now", instance.statImprovements[selection], 
			"out of", pointsPerLevel - instance.profArray[selection])
			
			if instance.statImprovements[selection] >= pointsPerLevel - instance.profArray[selection]:
				statAdjusts[selection] += 1
				instance.roomToGrow[selection] -= 1
				print(attribute, " has been fully improved! Increasing to ", statAdjusts[selection])
				instance.statImprovements[selection] = 0
				bannedSelects.append(selection)
			index += 1
		print("Level up complete!")
		pass
		
	instance.brawn = clampi(statAdjusts[Stats.Brawn], instance.minQuality, instance.maxQuality)
	instance.vigor = clampi(statAdjusts[Stats.Vigor], instance.minQuality, instance.maxQuality)
	instance.wit = clampi(statAdjusts[Stats.Wit], instance.minQuality, instance.maxQuality)
	instance.ambition = clampi(statAdjusts[Stats.Ambition], instance.minQuality, instance.maxQuality)
	instance.grace = clampi(statAdjusts[Stats.Grace], instance.minQuality, instance.maxQuality)
	instance.heart = clampi(statAdjusts[Stats.Heart], instance.minQuality, instance.maxQuality)
	
	print("Brawn:", instance.brawn)
	print("Vigor:", instance.vigor)
	print("Wit:", instance.wit)
	print("Ambition:", instance.ambition)
	print("Grace:", instance.grace)
	print("Heart:", instance.heart)
	instance.maxHP = (instance.heart*healthRatio)
	instance.maxHP = clampi(instance.maxHP, 1, instance.HPCap)
	instance.currentHP = instance.maxHP
	instance.maxMana = float(instance.brawn + instance.wit) / 2
	instance.currentMana = instance.maxMana
	instance.maxResolve = float(instance.vigor + instance.ambition) / 2
	prints("Max HP:", instance.maxHP,
	"Max Mana:", instance.maxMana,
	"Max Resolve:", instance.maxResolve)
	#End of reward assignment
	
	#Start of Movepool Population
	#print(learnList)
	for skill in learnList:
		#print(skill.skillName)
		if learnList[skill] <= instance.act:
			instance.learnedSkills.append(skill)
	#Fill out current slots with random skills from learnlist, replace with Most Recent later
	var highestSkill:int = instance.learnedSkills.size()-1
	for slot in range(instance.assignedSkills.size()):
		if highestSkill < 0 or instance.learnedSkills[highestSkill] == null:
			break
		instance.assignedSkills[slot] = instance.learnedSkills[highestSkill]
		highestSkill -= 1
	for skill in instance.assignedSkills:
		if skill == null:
			break
		print(skill.skillName)
	#End of Movepool Population
	
	if breakRoll == limitBreakOdds:
		print("Limit Break!")
	
	#Change out sprite for alt color if chances succeed.
	if shinyRoll == shinyOdds:
		print("Shiny!")
		instance.sprite = instance.shinySprite
	
	#Swap out sig school for one of two alt schools, if chances succeed
	if schoolRoll == altSchoolOdds:
		if RNG.randi_range(0,1) == 0:
			print("Alt School 1!")
			instance.sigSchool = instance.altSigSchool1
		else:
			print("Alt School 2!")
			instance.sigSchool = instance.altSigSchool2
	
	return instance


func CreateEncounter(enemyFaebles:Array[Faeble], levelGoal:int, _enemyWitch):
	var level:int = clampi(levelGoal - enemyFaebles.size(), 1, levelGoal)
	for faeble in enemyFaebles:
		if faeble == null:
			continue
		level += clampi(level+1, 1, levelGoal)
		CreateFaeble(faeble, level)
	var index:int = 0
	for faeble in FaebleStorage.enemyParty:
		if faeble == null:
			index += 1
			continue
		level += clampi(level+1, 1, levelGoal)
		print("Creating party instance of ", faeble.name)
		var faebleInstance = FaebleCreation.CreateFaeble(faeble, 4)
		FaebleStorage.enemyParty[index] = faebleInstance
		index += 1 

func LevelUp(faebleInstance:Faeble):
	pass

func AssignStats(faebleInstance:Faeble):
	pass
