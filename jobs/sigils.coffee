nodeio = require 'node.io'
util = require 'util'
path = require 'path'
_s = require 'underscore.string'
require 'coffee-script'
require '../profession/professions'
config = require '../config'
dbProvider = require "../db/#{config.db.provider}"

sigilLink = 'http://wiki.guildwars2.com/wiki/Sigil'

class Sigils extends nodeio.JobClass
	input: false
	run: () -> 
		sigils = {}

		@getHtml sigilLink, (err, $) => 
			$table = $('#bodyContent').find('table')
							
			setBegin = 0
			setEnd = 0					
			
			$rows = $table.find('tr:not(:first-child):not(.pve-only)')	
			
			while setEnd < $rows.length
				sigilSet = {}
				$sigilType  = $rows.eq(setBegin).find('th:first-child')

				setEnd = ($sigilType.attr('rowspan') * 1 or 1)+ setBegin

				sigils[$sigilType.text().trim()] = parse $, $rows[setBegin...setEnd]							

				setBegin = setEnd
						
			#console.log util.inspect sigils, false, null, true
			
			@emit sigils
	
	output: (sigils) ->
		dbProvider.save 'sigils', sigils[0]

parse = ($, rows) ->
	sigils = []

	for row, i in rows
		$row = $(row)
		$sigilData = $row.find('td')
		name = $sigilData.eq(0).find('a').text().trim()

		if name.indexOf('Minor') isnt -1 then continue

		sigils.push
			name: name
			description: $sigilData.last().text().trim()

	return sigils

@class = Sigils
@job = new Sigils
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