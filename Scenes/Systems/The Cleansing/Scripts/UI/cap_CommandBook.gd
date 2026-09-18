extends UIElement

@export var commandPages:Array[Node3D]
@export var attackButtons:Array[Node3D]

var option:int = -1
var action:int = -1
var detail:int = -1

signal Select(option:int,action:int,detail:int)


func PopulateAttacks(entry:BattlerData):
	#Insert Trick population segment here
	var i:int = 0
	for spell in attackButtons:
		if i == 0:
			i+=1
			continue
		if i == 4:
			break
		var spellEntry:Spell
		if entry.empoweredMoves[i-1] == true:
			spellEntry = entry.instance.assignedSpells[i-1].empowerment
		else:
			spellEntry = entry.instance.assignedSpells[i-1]
			if spellEntry == null:
				spell.hide()
				i+=1
				continue
			else:
				spell.show()
		var nametag:Label3D = spell.get_child(1)
		nametag.text = spellEntry.name
		print("Changing Attack Name To: ",spellEntry.name)
		#Insert Graphic replacement here
		i+=1
	i=0


func TopMenuButton(_viewport:Node, event:InputEvent, _event_position:Vector3, _normal:Vector3, _shape_idx:int, selection:int):
	if !event.is_action_pressed("LeftMouse"):
		return
	commandPages[0].hide()
	commandPages[selection].show()
	action = selection-1


func NavigationButton(_viewport:Node, event:InputEvent, _event_position:Vector3, _normal:Vector3, _shape_idx:int, selection:int):
	pass #Back buttons + Notes/Inspect, can also use controller bumpers


func FaebleMenuButton(_viewport:Node,event:InputEvent,_event_position:Vector3,_normal:Vector3,_shape_idx:int,selection:int,selectDetail:int=-1):
	if !event.is_action_pressed("LeftMouse"):
		return
	
	if selection == -1 and detail != -1:
		pass #Access switch menu and disable input from this menu
	elif selection == 0:#Back button
		selection = -1
		attackButtons[4].hide()
		commandPages[0].show()
		commandPages[1].hide()
		return
	elif selection == 4 and detail != -1:
		pass #Insert Trick and Advance/Retreat processing, detail is direction
	elif selection == 5:#Send final selection to battle system
		attackButtons[4].hide() #Change to 5
		emit_signal("Select",action,option,detail)
		action = -1
		option = -1
		detail = -1
	else:#Attack button selection
		option = selection-1
		attackButtons[4].show() #After selection, show cast circle + confirm button
		#TEMP, if empowered, display empowered spell effect


func WitchMenuButton(_viewport:Node,event:InputEvent,_event_position:Vector3,_normal:Vector3,_shape_idx:int,selection:int,selectDetail:int=-1):
	if !event.is_action_pressed("LeftMouse"):
		return
	#Rework to be like attack menu format, require immersion levels as redundancy
	match selection:
		0:#Back button
			selection = -1
			commandPages[0].show()
			commandPages[2].hide()
			return
		1: #Movement
			option = selection-1
			detail = selectDetail
			emit_signal("Select",action,option,detail)
			action = -1
			option = -1
			detail = -1
		2: #Switch
			option = selection-1
			#await TempPrepSwitch() #Trigger Switchout menu
		3: #Forfeit
			get_tree().quit() #VERY TEMP
