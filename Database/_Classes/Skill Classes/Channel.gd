extends Skill
class_name Channel

func Target(battleManager:BattleManager, user:Battler):
	battleManager.ChangeBoardState("Attacking")
	battleManager.CheckAttackRange(user, self)

func Execute(battleManager:BattleManager, user:Battler, target:Battler):
	var skillRegen = user.faebleEntry.maxEnergy - user.currentEnergy
	print("Regaining ", skillCost, " Energy.")
	user.ChangeEnergy(skillRegen)
	skillDamage = user.faebleEntry.tier
	skillType = user.faebleEntry.sigSchool
	if user.faebleEntry.brawn >= user.faebleEntry.wit:
		skillNature = "Physical"
	else:
		skillNature = "Magical"
	var damageTally:int
	damageTally = battleManager.DamageCalc(user, target, self)
	damageTally = -clampi(damageTally, 0, 99)
	var superFX:bool
	if -damageTally > skillDamage:
		superFX = true
	battleManager.DamagePopup(target.positionIndex, -damageTally, superFX)
	target.ChangeHealth(damageTally)
