extends Node3D

#Mostly reusable system for ritual casting, evidence board, etc
#Click and drag symbols/components (or stories/evidence) onto nodes in a graphic
#Based on "recipe" of filled slots, perform an action or call an event of another system
#Symbols define the spell and slots, each slot can be restricted to certain tags
#Components determine the outcome variables for spells with variance parameters
#(Symbols can be upgraded later on to change out their slot restrictions)

func OnPick():
	pass

func Drag():
	pass

func OnRelease():
	pass

func InitializeCircle():
	pass

func AssignSlots():
	pass #when a symbol is placed, reorder slots to spell, with tag restrictions assigned

func ClearSlots():
	pass #remove components from all slots back to bag

func CheckSlots():
	pass #cycle through each slot and gray-out any with tags that don't match current selection

func CastSpell():
	pass #may need separate function per spell, in which case use this for Symbol match case
