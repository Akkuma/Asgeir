nodeio = require 'node.io'
util = require 'util'
path = require 'path'
_s = require 'underscore.string'
require 'coffee-script'
require '../profession/professions'
config = require '../config'
dbProvider = require "../db/#{config.db.provider}"

runesLink = 'http://wiki.guildwars2.com/wiki/Rune'

class Runes extends nodeio.JobClass
	input: false
	run: () -> 
		runes = {}

		@getHtml runesLink, (err, $) => 
			$('#bodyContent').find('table:not(#toc)').each (k,v) =>
				$table = $(v)
				$rows = $table.find('tr:not(:first-child)')	

				setBegin = setEnd = 0			
				
				type = $table.prev().find('span').last().text().trim()

				while setEnd < $rows.length
					runeName  = $rows.eq(setBegin).find('th:first-child').text().trim()

					setEnd = setBegin += 2					

					runes[type] = {} unless runes[type]
					runes[type][runeName] = parse $, $rows[setBegin..setEnd]			

					setEnd = ++setBegin
							
			console.log util.inspect runes, false, null, true
			@emit runes
	
	output: (runes) ->
		console.log 'WTFMATE'
		dbProvider.runes runes[0]

parse = ($, row) ->
	bonuses = []

	$(row).find('td').each (k, v) ->
		bonuses.push $(v).text().trim()

	return bonuses

@class = Runes
@job = new Runes
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