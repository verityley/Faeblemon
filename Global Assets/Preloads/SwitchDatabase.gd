extends Node

@export_category("Global Switches")
@export var switch001:bool #Name Variables 
@export var switch002:bool
@export var switch003:bool
@export var switch004:bool

@export_category("Gameplay Switches")
@export var switch005:bool
@export var switch006:bool
@export var switch007:bool
@export var switch008:bool

@export_category("Event Switches")
@export var switch009:bool
@export var switch010:bool
@export var switch011:bool
@export var switch012:bool

@export_category("System Switches")
@export var switch013:bool
@export var switch014:bool
@export var switch015:bool
@export var switch016:bool

@export_category("Global Variables")
@export var var001:int
@export var var002:int
@export var var003:int
@export var var004:int

@export_category("Gameplay Variables")
@export var var005:int
@export var var006:int
@export var var007:int
@export var var008:int

@export_category("Event Variables")
@export var var009:int
@export var var010:int
@export var var011:int
@export var var012:int

@export_category("System Variables")
@export var var013:int
@export var var014:int
@export var var015:int
@export var var016:int


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
