module.exports =
	before: (skillset) ->
		skillset.subset = skillset.type
		[name, type] = skillset.name.split('(')
		skillset.hand = type.replace(')','') unless skillset.hand
		skillset.type = skillset.hand
		skillset.name = name

