extends Node
class_name RulesList

@export var baseRules:Array[Rule]
@export var sceneRules:Array[Rule]
@export var currentRules:Array[Array]

var topWinCon:Rule
var topNCResult:Rule
var tiebreaker:Rule


func OrganizeRules():
	#Iterate through rules layers in order
	currentRules.clear()
	var layer0:Array[Rule]
	var layer1:Array[Rule]
	var layer2:Array[Rule]
	var layer3:Array[Rule]
	var layer4:Array[Rule]
	var layer5:Array[Rule]
	for rule in baseRules:
		match rule.layer:
			0: layer0.append(rule)
			1: layer1.append(rule)
			2: layer2.append(rule)
	for rule in sceneRules:
		match rule.layer:
			0: layer0.append(rule)
			1: layer1.append(rule)
			2: layer2.append(rule)
			3: layer3.append(rule)
			4: layer4.append(rule)
			5: layer5.append(rule)
	currentRules.append(layer5)
	currentRules.append(layer4)
	currentRules.append(layer3)
	currentRules.append(layer2)
	currentRules.append(layer1)
	currentRules.append(layer0)
	#For each layer, proceed through each rule in turn, if rule.Conditional pass, run rule.Outcome
	#Decide if rule validity is determined here, by source present, or by removing rule if source leaves
	#if signal occurs, add to wincon/results/etc if not already full
	pass 
