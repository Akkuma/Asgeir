nodeio = require 'node.io'
util = require 'util'
path = require 'path'
_s = require 'underscore.string'
require 'coffee-script'
require './profession/professions'

class Skills extends nodeio.JobClass
	input: ['thief']
	run: (profession) -> 
		skillLink = 'http://wiki.guildwars2.com/wiki/List_of_%s_skills'
		skills = {}

		@getHtml util.format(skillLink, profession), (err, $) => 
			$('table').each (k,v) ->
				map = idMapping[v.id]
				
				if map					
					file = "./profession/#{profession}/skills/#{v.id.substring 0, v.id.indexOf('-')}.coffee"
					parser = if path.existsSync file  then require file else {} 
					
					collection = {}
					setBegin = 0
					setEnd = 0					
					
					$table = $(v)
					$rows = $table.find('tr:not(:first-child)')		
					$headers = $table.find('tr:first-child')			
					
					while setEnd < $rows.length
						skillset = {}
						$skillCollection  = $rows.eq(setBegin).find('th:first-child')
						skillset.name = $skillCollection.text().trim()

						setEnd = $skillCollection.attr('rowspan') * 1 + setBegin
						
						$set = $($rows[setBegin...setEnd])
						subsetBegin = 0
						subsetEnd = 0 
						#console.log "Set: #{$set.length}"
						while subsetEnd < $set.length
							$skillType = $set.eq(subsetBegin).find('th').not($skillCollection)
							skillset.type = $skillType.text().trim()
						
							subsetEnd = $skillType.attr('rowspan') * 1 + subsetBegin
							skillset.rows = $set[subsetBegin...subsetEnd]
							#console.log "begin: #{subsetBegin} to end #{subsetEnd}"
							parser.before skillset if parser.before							
							subcollection = parse $, skillset, $headers	

							collection[skillset.type] = {} unless collection[skillset.type]
							collection[skillset.type][skillset.name] = {} unless collection[skillset.type][skillset.name]

							if skillset.subset
								collection[skillset.type][skillset.name][skillset.subset] = 
									skills: subcollection
							else
								collection[skillset.type][skillset.name].skills = subcollection

							subsetBegin = subsetEnd
						
						setBegin = setEnd

					parser.after collection if parser.after
					console.log util.inspect collection, false, null, true

			
			@emit skills
	
	output: (skills) ->
		#console.log util.inspect skills, false, null, true

parse = ($, skillset, $headers) ->
	skillset.type = skillset.type.replace(/\W/gi, '').toLowerCase()

	rechargeName = $headers.find('th').eq(3).text().trim().toLowerCase()
	skills = []

	for row, i in skillset.rows
		$row = $(row)
		$skillData = $row.find('td')
		skill =
			name: $skillData.eq(0).find('a').text().trim()
			description: $skillData.eq(2).text().trim()

		skill[rechargeName] = $skillData.eq(1).text().trim() * 1 or 0

		isChain = $skillData.eq(0).find("img[alt='Redirect Arrow.png']").length
		
		if isChain
			previousSkill = skills[skills.length - 1]
			previousSkill.chain = [] unless previousSkill.chain
			previousSkill.chain.push skill
		else if skill
			skills.push skill


	#console.log util.inspect collection, false, null, true

	return skills

parseWeaponSkills = (collection) ->
	return collection

parseDownedSkills= () ->
parseSlotSkills= () ->
parseProfessionMechanicSkills= () ->
idMapping =
	'weapon-skills': 
		parser: parseWeaponSkills
		collection: 'weapons'
	###
	'downed-skills': parseDownedSkills
	'slot-skills': parseSlotSkills
	'profession-mechanic-skills': parseProfessionMechanicSkills
	###

@class = Skills
@job = new Skills
			timeout:1200
			jsdom: true

###
Generic
	skills
		weapon
			mainhand
			bothhands
			offhand
				[weapon name]
					*burstSkill
					*stealthSkill
					skills
		slot
			healing
			utility
			elite
		downed
		profession


		skills.weapon.mainhand.sword.air