module.exports =
	after: (collection) -> 
		for weaponName of collection
			weapon = collection[weaponName]
			weapon.burstSkill = weapon.burstSkill?.skills[0]