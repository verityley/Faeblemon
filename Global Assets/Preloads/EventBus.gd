extends Node

#signal put_name_here(parameter:type, paremeter2:type)
#EventBus.connect("put_name_here", AttachedFunction)
#EventBus.emit_signal("put_name_here", parameter1, parameter2)

#Global Signals
#signal quit
#signal pause
#signal save

#NPC Signals
signal MoveNPC(npc:NPC, event:Event, location:Vector3)
signal InteractNPC(npc:NPC)
signal PassbyNPC(npc:NPC)
signal BattleNPC(npc:NPC, event:Event, team:Array[Faeble], stage:Stage)
signal GossipNPC(npc:NPC, event:Event, message:Message)
signal TalkNPC(npc:NPC, event:Event, message:Message)
signal InterviewNPC(npc:NPC, event:Event, message:Message, speaker:Speaker, stage:Stage)
signal CancelEvents(npc:NPC)
signal ProgressQuest(quest:Questline)


#Overworld Signals
signal LockAll(locked:bool)


#Battle Signals
signal TargetBattle(selected:bool, choice:int, stage:int)
signal TargetMana(selected:bool, choice:int)

#Menu Signals
signal TargetMenu
signal TargetChoice(selected:bool, choice:int)
#signal open menu
#signal menu1, 2, 3, etc (Party, bag, journal, etc)
#signal close all

#Gameflow Signals (Cutscenes, etc)
#signal halt all
#signal resume all
