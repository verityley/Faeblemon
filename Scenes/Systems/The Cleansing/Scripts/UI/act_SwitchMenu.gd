extends UIElement

var deathSwitch:bool
var playerSelect:bool #TEMP
var enemySelect:bool #TEMP
var queueSelect:bool #TEMP
var currentSwitch:int = -1 #input int, if same as before treat as confirmation
@export var bookmarks:Array[Node3D]
@export var backButton:Node3D

var detail:int = -1

func PopulateMenu(current:Faeble, team:Array[Faeble], showback:bool=true):
	#Prep all bookmarks to party, then show back button+fade cover, cascade down show
	await ShiftShow(1.0)
	var i:int = 0
	for mark in bookmarks:
		if i >= team.size():
			break
		if i == 0:
			mark.SetupSlot(current)
		else:
			mark.SetupSlot(team[i])
		mark.ShiftShow()
		await get_tree().create_timer(0.1).timeout
		i += 1
	if showback:
		backButton.show()
	else:
		backButton.hide()
	pass

func ResetMenu():
	backButton.hide()
	for mark in bookmarks:
		mark.ShiftHide()
		await get_tree().create_timer(0.1).timeout
	await ShiftHide(1.0)

func PartyMenuButton(_viewport:Node, event:InputEvent, _event_position:Vector3, _normal:Vector3, _shape_idx:int, selection:int):
	if !event.is_action_pressed("LeftMouse"):
		return
	if selection == -1:
		if currentSwitch != -1:
			await bookmarks[currentSwitch].DisplaySlot(true)
		ResetMenu()
		currentSwitch = -1
		#ShowUI() #Needs better reference check back to main UI
		#commandPages[3].show()
		#commandPages[0].hide()
		return
	if currentSwitch != selection:
		bookmarks[currentSwitch].DisplaySlot(true)
	var result:bool = bookmarks[selection].DisplaySlot()
	await get_tree().create_timer(0.5).timeout #TEMP
	currentSwitch = selection
	if result:
		currentSwitch = -1
		detail = selection
		pass #Send detail info up to UIManager
		#battleSystem.Selection(battleSystem.enemyBattler,action,option,detail)
		#await ShowUI()
	pass
