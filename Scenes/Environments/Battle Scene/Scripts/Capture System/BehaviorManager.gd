extends Node3D

@export var captureSystem:Node3D

#External Variables
var currentPath:int #The current intended path to take in the loaded path enum/array
var patience:int #This is changed by Personality based on certain actions. At 0, retreat.
var posing:bool #true as long as pose anim is up

#Setup Variables


#Internal Variables


#Setup Functions


#Process Functions


#Data-Handling Functions


#Tangible Action Functions



#placeholder order of operations:
#Use this script every attempt, or every time call, or wait for path complete
#patience check, if 0, go to retreat functions in CS
#check %chance for pause 'n' pose, if pass, break function and pose until next timecall/anim length
#Otherwise, queue up next path. Sometimes a chance for the same path, esp playful
#Some personalities might change their path on attempt vs time call
#Send signal to path manager(or CS to send to PM)
#Finally, check for patience decrease based on time call/attempt trigger/etc
#send signals to CS if needed
