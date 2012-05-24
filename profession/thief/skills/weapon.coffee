module.exports =
	before: (skillset) ->
		if skillset.type.indexOf(' alone') > -1 or skillset.type.length is skillset.name.length 
			delete skillset.subset
			return

		if skillset.type.indexOf(skillset.name) is 0 
			skillset.subset = skillset.type.split('+')[1].trim()
			skillset.type = skillset.hand			
		else
			skillset.hand = skillset.type

	after: (collection) ->
		for skill of collection.stealthskill

			if collection.bothhands[skill]
				weapon = collection.bothhands[skill]
			else if collection.mainhand[skill]
				weapon = collection.mainhand[skill]
			else if collection.aquatic[skill]
				weapon = collection.aquatic[skill]

			weapon.stealthSkill = collection.stealthskill[skill].skills[0]

		delete collection.stealthskill

		for skill of collection.mainhand
			delete collection[skill.toLowerCase()+'alone']