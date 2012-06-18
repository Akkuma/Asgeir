nodeio = require 'node.io'
util = require 'util'
path = require 'path'
_s = require 'underscore.string'
require 'coffee-script'
require '../profession/professions'
config = require '../config'
dbProvider = require "../db/#{config.db.provider}"

skillLink = 'http://wiki.guildwars2.com/wiki/List_of_%s_skills'

class Skills extends nodeio.JobClass
	input: professions
	run: (profession) -> 
		skills = {}

		@getHtml util.format(skillLink, profession), (err, $) => 
			$('table').each (k,v) =>
				map = idMapping[v.id]
				
				if map					
					file = "./profession/#{profession}/skills/#{map}.coffee"
					parser = if path.existsSync file then require file else {} 
					
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

						setEnd = ($skillCollection.attr('rowspan') * 1 or 1)+ setBegin
						
						$set = $($rows[setBegin...setEnd])
						subsetBegin = 0
						subsetEnd = 0 
						
						#console.log "Set: #{$set.length}"
						
						while subsetEnd < $set.length
							$skillType = $set.eq(subsetBegin).find('th').not($skillCollection)
							skillset.type = $skillType.text().trim()

							subsetEnd = ($skillType.attr('rowspan') * 1 or 1) + subsetBegin
							skillset.rows = $set[subsetBegin...subsetEnd]
							
							#console.log "begin: #{subsetBegin} to end #{subsetEnd}"
							
							parser.before? skillset					
							subcollection = parse $, skillset, $headers	
								
							base = collection[skillset.name] = {} unless collection[skillset.name]
							base = collection[skillset.name][skillset.type] = {} unless collection[skillset.name][skillset.type]

							if skillset.subset								
								base = collection[skillset.name][skillset.type][skillset.subset] = {}
							
							base.skills = subcollection

							subsetBegin = subsetEnd

						setBegin = setEnd

					parser.after? collection
					
					skills[map] = collection
					#console.log util.inspect collection, false, null, true
			
			#console.log util.inspect skills, false, null, true
			
			@emit name: profession, skills: skills
	
	output: (profession) ->
		dbProvider.save 'skills', profession[0]

parse = ($, skillset, $headers) ->
	type = skillset.type.replace(/[^\w\s]/g, '').split(' ')
	type[0] = type[0].toLowerCase()
	skillset.type = _s.camelize(type.join(' '))

	rechargeName = $headers.find('th').eq(3).text().trim().toLowerCase()
	skills = []

	for row, i in skillset.rows
		$row = $(row)
		$skillData = $row.find('td')
		skill =
			name: $skillData.eq(0).find('a').text().trim()
			description: $skillData.last().text().trim()

		skill[rechargeName] = $skillData.eq(1).text().trim() * 1 or 0

		isChain = $skillData.eq(0).find("img[alt='Redirect Arrow.png']").length
		
		if isChain
			previousSkill = skills[skills.length - 1]
			previousSkill.chain = [] unless previousSkill.chain
			previousSkill.chain.push skill
		else if skill
			skills.push skill


	#console.log util.inspect skills, false, null, true

	return skills

idMapping =	
	'weapon-skills': 'weapon'
	'slot-skills': 'slot'
	'transform-skills': 'transform'
	'downed-skills': 'downed'
	'profession-mechanic-skills': 'professionMechanic'

@class = Skills
@job = new Skills
			timeout: 1200
			jsdom: true
			auto_retry: true
###
Generic
	skills
		weapon
			[weapon name]
				*burstSkill
				*stealthSkill
				mainhand
				bothhands
				offhand
					skills
		slot
			healing
			utility
			elite
		downed
		profession


		skills.weapon.dagger.mainhand.air
###