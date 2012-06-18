module.exports =
	before: (skillset) ->
		if skillset.type.toLowerCase().indexOf(' alone') > -1 or skillset.type.length is skillset.name.length 
			delete skillset.subset
			return

		if skillset.type.indexOf(skillset.name) is 0 
			skillset.subset = skillset.type.split('+')[1].trim()
			skillset.type = skillset.hand			
		else
			skillset.hand = skillset.type

	after: (collection) ->
		for weaponName of collection
			weapon = collection[weaponName]
			weapon.stealthSkill = weapon.stealthSkill?.skills[0]

			delete weapon[weaponName.toLowerCase()+'Alone']