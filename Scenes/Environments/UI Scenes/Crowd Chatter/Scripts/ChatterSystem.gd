extends Node3D

#The chatter system is an overlay to environments that produces and moves around
#small chat bubbles across the screen, with differing paths based on the scene
#these can be clicked to gain their rumor/push them off the screen


func SpawnBubble():
	pass #Create a new chatter bubble and assign to a path

func RemoveBubble():
	pass 

func ProgressPath():
	pass #Start and run tween for chatter bubble on path (node3d array) until next position index

func ChangePath():
	pass #Removes the target bubble from one path index, and adds to another

func OnClick():
	pass #Depending on bubble contents, send to rumor inventory or push out of the way/remove

func ChatterTimer():
	pass #Used to set an overall time count and timer UI resource for how long chatter will last
	#as well as when to trigger certain spawn or movement events

func Sequence():
	pass #Called by the timer at intervals, or by environment pattern triggers
	#passes along spawn, remove, or path change events to the rest of the system
