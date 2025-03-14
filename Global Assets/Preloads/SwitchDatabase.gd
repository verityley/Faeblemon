extends Node

#signal put_name_here(parameter:type, paremeter2:type)
#EventBus.connect("put_name_here", AttachedFunction)
#EventBus.emit_signal("put_name_here", parameter1, parameter2)

#signal switchGlobal(key:String, value:bool)
#EventBus.connect("switchGlobal", AttachedFunction)
#EventBus.emit_signal("put_name_here", parameter1, parameter2)

@export var globalSwitches:Dictionary[String,bool]

@export var gameSwitches:Dictionary[String,bool]

@export var eventSwitches:Dictionary[String,bool]

@export var systemSwitches:Dictionary[String,bool]

@export var globalTallies:Dictionary[String,int]

@export var gameTallies:Dictionary[String,int]

@export var eventTallies:Dictionary[String,int]

@export var systemTallies:Dictionary[String,int]


#signal put_name_here(parameter:type, paremeter2:type)
#EventBus.connect("put_name_here", AttachedFunction)
#EventBus.emit_signal("put_name_here", parameter1, parameter2)

#Global Signals
#signal quit
#signal pause
#signal save

#Overworld Signals


#Battle Signals


#Menu Signals
#signal open menu
#signal menu1, 2, 3, etc (Party, bag, journal, etc)
#signal close all

#Gameflow Signals (Cutscenes, etc)
#signal halt all
#signal resume all
