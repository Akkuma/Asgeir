nodeio = require 'node.io'
util = require 'util'
path = require 'path'
_s = require 'underscore.string'
require 'coffee-script'
require './profession/professions'

class Skillz extends nodeio.JobClass
	input: professions
	run: (profession) -> 
		skillLink = 'http://wiki.guildwars2.com/wiki/List_of_%s_skills'
		skills = {}

		@getHtml util.format(skillLink, profession), (err, $) => 
			$('table').each (k,v) ->
				map = idMapping[v.id]
				
				if map					
					file = "./profession/#{profession}/skills/#{v.id.substring 0, v.id.indexOf('-')}.coffee"
					processor = if path.existsSync file  then require file else {} 
					
					#collection = []
					setBegin = 0
					setEnd = 0					
					
					$table = $(v)
					$rows = $table.find('tr:not(:first-child)')		
					$headers = $table.find('tr:first-child')			
					
					while setEnd < $rows.length
						$skillCollection  = $rows.eq(setBegin).find('th:first-child')
						skillCollectionName = $skillCollection.text().trim()

						setEnd = $skillCollection.attr('rowspan') * 1 + setBegin
						
						$set = $($rows[setBegin...setEnd])
						subsetBegin = 0
						subsetEnd = 0 
						#console.log "Set: #{$set.length}"
						while subsetEnd < $set.length
							$skillType = $set.eq(subsetBegin).find('th').not($skillCollection)
							skillTypeName = $skillType.text().trim()
						
							subsetEnd = $skillType.attr('rowspan') * 1 + subsetBegin

							#console.log "begin: #{subsetBegin} to end #{subsetEnd}"
							map.parser $, 
								$set[subsetBegin...subsetEnd], 
								skillCollectionName, 
								skillTypeName
								$headers
							

							subsetBegin = subsetEnd
						
						setBegin = setEnd

					#skills[map.collection] = collection

			@emit skills
	
	output: (skills) ->
		#console.log util.inspect skills, false, null, true

parseWeaponSkills = ($, rows, name, hand, $headers) ->
	
	wpn = 
		type: hand.replace(/\W/gi, '').toLowerCase()
		name: name
		skills: []

	for row, i in rows
		$row = $(row)
		$skillData = $row.find('td')
		skill =
			skill: $skillData.eq(0).find('a').text().trim()
			description: $skillData.eq(2).text().trim()

		skill[$headers.find('th').eq(3).text().trim().toLowerCase()] = $skillData.eq(1).text().trim() * 1

		isChain = $skillData.eq(0).find("img[alt='Redirect Arrow.png']").length
		
		if isChain
			previousSkill = wpn.skills[wpn.skills.length - 1]
			previousSkill.chain = [] unless previousSkill.chain
			previousSkill.chain.push skill
		else if skill
			wpn.skills.push skill


	console.log util.inspect wpn, false, null, true

	return wpn

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

@class = Skillz
@job = new Skillz
			timeout:1200
			jsdom: true