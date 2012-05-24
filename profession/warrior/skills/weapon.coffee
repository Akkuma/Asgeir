module.exports =
	after: (collection) -> 
		for skill of collection.burstskill

			if collection.bothhands[skill]
				weapon = collection.bothhands[skill]
			else if collection.mainhand[skill]
				weapon = collection.mainhand[skill]
			else if collection.aquatic[skill]
				weapon = collection.aquatic[skill]

			weapon.burstSkill = collection.burstskill[skill].skills[0]

		delete collection.burstskill