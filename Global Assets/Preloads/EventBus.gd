extends Node

#signal put_name_here(parameter:type, paremeter2:type)
#EventBus.connect("put_name_here", AttachedFunction)
#EventBus.emit_signal("put_name_here", parameter1, parameter2)

#Global Signals
#signal quit
#signal pause
#signal save

#Overworld Signals


#Battle Signals
signal TargetBattle(selected:bool, choice:int, stage:int)

#Menu Signals
signal TargetMenu
signal TargetChoice
#signal open menu
#signal menu1, 2, 3, etc (Party, bag, journal, etc)
#signal close all

#Gameflow Signals (Cutscenes, etc)
#signal halt all
#signal resume all
