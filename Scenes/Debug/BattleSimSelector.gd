extends Control

@export var isAlly:bool
@export var familiarList:Array[Faeble]
@onready var header = $Info/Header
@onready var familiarInput = $Info/Header/FamiliarSelector
@onready var levelInput = $Info/Header/FamiliarSelector/LineEdit
@onready var battlerDisplay = $Info/BattlerPanel
@onready var familiarDisplay = $Info/BattlerPanel/FamiliarDisplay
@onready var domain1Display = $Info/BattlerPanel/Domain1Display
@onready var domain2Display = $Info/BattlerPanel/Domain2Display
@onready var schoolDisplay = $Info/BattlerPanel/SigSchoolDisplay
@onready var moveInput1 = $Info/MoveInput1
@onready var moveInput2 = $Info/MoveInput2
@onready var moveInput3 = $Info/MoveInput3
@onready var statsPanel = $Info/StatsPanel
@onready var bwnDisplay = $Info/StatsPanel/BwnDisplay
@onready var vigDisplay = $Info/StatsPanel/VigDisplay
@onready var witDisplay = $Info/StatsPanel/WitDisplay
@onready var ambDisplay = $Info/StatsPanel/AmbDisplay
@onready var grcDisplay = $Info/StatsPanel/GrcDisplay
@onready var resDisplay = $Info/StatsPanel/ResDisplay
@onready var hrtDisplay = $Info/StatsPanel/HrtDisplay

@onready var pointsPanel = $Info/PointsPanel
@onready var hpDisplay = $Info/PointsPanel/HPDisplay
@onready var engDisplay = $Info/PointsPanel/EngDisplay
@onready var movDisplay = $Info/PointsPanel/MovDisplay

#@onready var finishButton = $Info/FinishButton

var selectorIndex:int

var nextScene = load("res://Scenes/Debug/DebugTeamSelector.tscn")


var selectedFamiliar:Faeble
var newFamiliar:Faeble
var moveList:Array[Skill]

# Called when the node enters the scene tree for the first time.
func _ready():
	Reset()
	familiarInput.clear()
	for faeble in FaebleStorage.codex:
		familiarList.append(FaebleStorage.codex[faeble])
		familiarInput.add_item(faeble)
	familiarInput.select(-1)
	if isAlly == false:
		$Info.self_modulate = Color(164, 0, 0)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func Reinitialize():
	Reset()
	familiarInput.clear()
	for faeble in FaebleStorage.codex:
		familiarList.append(FaebleStorage.codex[faeble])
		familiarInput.add_item(faeble)
	familiarInput.select(-1)
	if isAlly == false:
		$Info.self_modulate = Color(164, 0, 0)

func Reset():
	if isAlly == true:
		header.text = "Choose your Familiar!"
	else:
		header.text = "Choose your Opponent!"
	#familiarInput.select(-1)
	#selectedFamiliar = null
	levelInput.text = ""
	levelInput.hide()
	battlerDisplay.hide()
	moveInput1.hide()
	moveInput2.hide()
	moveInput3.hide()
	statsPanel.hide()
	pointsPanel.hide()
	#finishButton.hide()
	moveList.clear()
	moveInput1.clear()
	moveInput2.clear()
	moveInput3.clear()


func _on_familiar_selected(index):
	Reset()
	if selectedFamiliar != null:
		#selectedFamiliar.queue_delete()
		selectedFamiliar = null
	selectedFamiliar = familiarList[index]
	print(selectedFamiliar.name)
	levelInput.show()
	battlerDisplay.show()
	familiarDisplay.texture = selectedFamiliar.sprite
	domain1Display.texture = selectedFamiliar.firstDomain.nameplate
	if selectedFamiliar.secondDomain != null:
		domain2Display.texture = selectedFamiliar.secondDomain.nameplate
	else:
		domain2Display.texture = null
	schoolDisplay.texture = selectedFamiliar.sigSchool.nameplate



func _on_level_changed(new_text):
	moveInput1.clear()
	moveInput2.clear()
	moveInput3.clear()
	moveInput1.get_child(0).texture = null
	moveInput2.get_child(0).texture = null
	moveInput3.get_child(0).texture = null
	moveList.clear()
	statsPanel.show()
	pointsPanel.show()
	
	var levelNum = int(levelInput.text)
	if levelNum > 20:
		levelNum = clamp(levelNum, 1, 20)
		levelInput.text = str(levelNum)
		
	if levelInput.text != "" and levelNum != 0:
		newFamiliar = FaebleCreation.CreateFaeble(selectedFamiliar, levelNum)
		newFamiliar.assignedSkills.resize(3)
		for skill in newFamiliar.skillPool:
			if newFamiliar.skillPool[skill] <= newFamiliar.level:
				moveList.append(skill)
		moveInput1.show()
		moveInput2.show()
		moveInput3.show()
		for skill in moveList:
			moveInput1.add_item(skill.skillName)
			moveInput2.add_item(skill.skillName)
			moveInput3.add_item(skill.skillName)
		moveInput1.select(-1)
		moveInput2.select(-1)
		moveInput3.select(-1)
	
	bwnDisplay.text = str(newFamiliar.brawn)
	vigDisplay.text = str(newFamiliar.vigor)
	witDisplay.text = str(newFamiliar.wit)
	ambDisplay.text = str(newFamiliar.ambition)
	grcDisplay.text = str(newFamiliar.grace)
	resDisplay.text = str(newFamiliar.resolve)
	hrtDisplay.text = str(newFamiliar.heart)
	
	hpDisplay.text = str(newFamiliar.maxHP)
	engDisplay.text = str(newFamiliar.maxEnergy)
	movDisplay.text = str(floor(float(newFamiliar.grace)/5)+1)


func _on_move_selected(index, selectorIndex):
	if selectorIndex == 1:
		moveInput1.get_child(0).texture = moveList[index].skillType.nameplate
	elif selectorIndex == 2:
		moveInput2.get_child(0).texture = moveList[index].skillType.nameplate
	elif selectorIndex == 3:
		moveInput3.get_child(0).texture = moveList[index].skillType.nameplate
	
	newFamiliar.assignedSkills[selectorIndex-1] = moveList[index]
	print(newFamiliar.assignedSkills)
	#finishButton.show()

#
#func _on_finish_pressed():
	#if selectorIndex < 3:
		##newFamiliar.currentHP = newFamiliar.maxHP
		#FaebleStorage.playerParty[selectorIndex] = newFamiliar
		#var current = self
		#var instance = nextScene.instantiate()
		#get_tree().get_root().add_child(instance)
		#instance.selectorIndex = (selectorIndex + 1)
		#instance.Reinitialize()
		#get_tree().get_root().remove_child(current)
		#current.call_deferred("free")
		#
	#elif selectorIndex >= 3:
		#newFamiliar.currentHP = newFamiliar.maxHP
		#FaebleStorage.playerParty[selectorIndex] = newFamiliar
		#nextScene = load("res://Scenes/Battle/BattleStage.tscn")
		#var current = self
		#var instance = nextScene.instantiate()
		#get_tree().get_root().add_child(instance)
		##instance.get_node("BattleManager").EnterBattle(PlayerParty.testBattler, PlayerParty.testOpponent)
		#instance.get_node("BattleManager").BattleSetup()
		#get_tree().get_root().remove_child(current)
		#current.call_deferred("free")
