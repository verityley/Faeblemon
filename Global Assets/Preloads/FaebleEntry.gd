extends Node

@export var playerParty:Array[Faeble]
@export var maxPartySize:int = 6
@export var playerCity:Array[Faeble]
var battleFaebles:Array[Faeble]

@export var limitBreakOdds:int = 800 #These are all "1 out of X", not the percent chance.
@export var shinyOdds:int = 1000
@export var altSchoolOdds:int = 500

@export var rewardRatio:Vector2i = Vector2i(4,2)
@export var heartRatio:Vector2i = Vector2i(2,3)
@export var energyRatio:Vector2i = Vector2i(1,1)

func _ready():
	#CreateFaeble(preload("res://Database/Faebles/Ananseed.tres"), 8)
	pass


func CreateFaeble(faebleEntry:Faeble, initLevel:int, mook:bool = false, commander:Faeble = null) -> Faeble:
	var instance:Faeble = faebleEntry.duplicate()
	
	var RNG = RandomNumberGenerator.new()
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
		
		statRoll = RNG.randi_range(0,6)
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
	
	#Start of Stat Assignment
	instance.brawn = clampi(instance.brawn + instance.profArray[0], instance.minQuality, instance.maxQuality)
	print("Brawn: ", instance.brawn)
	instance.vigor = clampi(instance.vigor + instance.profArray[1], instance.minQuality, instance.maxQuality)
	print("Vigor: ", instance.vigor)
	instance.wit = clampi(instance.wit + instance.profArray[2], instance.minQuality, instance.maxQuality)
	print("Wit: ", instance.wit)
	instance.ambition = clampi(instance.ambition + instance.profArray[3], instance.minQuality, instance.maxQuality)
	print("Ambition: ", instance.ambition)
	instance.grace =  clampi(instance.grace + instance.profArray[4], instance.minQuality, instance.maxQuality)
	print("Grace: ", instance.grace)
	instance.resolve = clampi(instance.resolve + instance.profArray[5], instance.minQuality, instance.maxQuality)
	print("Resolve: ", instance.resolve)
	instance.heart = clampi(instance.heart + instance.profArray[6], instance.minQuality, instance.maxQuality)
	print("Heart: ", instance.heart)
	
	#Start of ASI and Level-up reward Assignment
	instance.level = initLevel
	instance.traitImprovements = floori(float(initLevel) / 4) * 2 #Gain 2 points every 4 levels
	prints("Level:", instance.level, "Current ASIs:", instance.traitImprovements)
	for i in range(initLevel - 1):
		if RNG.randi_range(1,rewardRatio.x + rewardRatio.y) > rewardRatio.y:
			instance.hpIncreases += 1
		else:
			instance.energyIncreases += 1
	
	instance.maxHP = (instance.heart*heartRatio.x) + (instance.hpIncreases*heartRatio.y)
	var baseEnergy:int = float(instance.brawn + instance.wit) / 2
	instance.maxEnergy = (baseEnergy*energyRatio.x) + (instance.energyIncreases*energyRatio.y)
	prints("HP Increases:", instance.hpIncreases, "Energy Increases:", instance.energyIncreases)
	prints("Max HP:", instance.maxHP, "Max Energy:", instance.maxEnergy)
	#End of reward assignment
	
	#Start of Movepool Population
	for skill in instance.skillPool:
			if instance.skillPool[skill] <= instance.level:
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
		if mook == true:
			pass #Send this shiny roll to the commander instead
	
	#Change out sprite for alt color if chances succeed.
	if shinyRoll == shinyOdds:
		print("Shiny!")
		if mook == true:
			pass #Send this shiny roll to the commander instead
		instance.sprite = instance.shinySprite
	
	#Swap out sig school for one of two alt schools, if chances succeed
	if schoolRoll == altSchoolOdds:
		if mook == true:
			pass #Send this shiny roll to the commander instead
		if RNG.randi_range(0,1) == 0:
			print("Alt School 1!")
			instance.sigSchool = instance.altSigSchool1
		else:
			print("Alt School 2!")
			instance.sigSchool = instance.altSigSchool2
	
	return instance


func AddToParty(faebleInstance:Faeble):
	if playerParty.size() >= maxPartySize:
		print("Party too full, give choice to swap and send one to city.")
	else:
		pass

func AddToCity(faebleInstance:Faeble):
	pass

func EnterBattle(faebleInstance:Faeble, enemy:bool): #This should specifically create a *battle* instance
	pass

func LevelUp(faebleInstance:Faeble):
	pass

func AssignStats(faebleInstance:Faeble):
	pass
