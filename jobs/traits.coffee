nodeio = require 'node.io'
util = require 'util'
require 'coffee-script'
require '../profession/professions'
config = require '../config'
dbProvider = require "../db/#{config.db.provider}"

class Traits extends nodeio.JobClass
	input: professions
	run: (profession) -> 
		traitLink = 'http://wiki.guildwars2.com/wiki/List_of_%s_traits'
		traitLines = []

		@getHtml util.format(traitLink, profession), (err, $) => 
			$rows = $ '#traits tr:not(:first-child)' 
			$trait = $rows.first().find('th:first')
			numOfTraitsPerLine = $trait.attr('rowspan')

			traitLine = {}
			$rows.each (k,v) ->
				$row = $(v)
				$description = $row.children().last()
				$name = $description.prev()
				traitLineIndex = k % numOfTraitsPerLine

				if traitLineIndex is 0
					$traitLineCell = $row.find('th:first')					
					numOfTraitsPerLine = $traitLineCell.attr('rowspan')

					traitLine = 
						name: $traitLineCell.children('b').text()
						traits: {}
						attributes: []

					$attributes = $traitLineCell.find('p').not(':first');
					i = -1
					while ++i isnt 2
						attribute = $attributes.eq(i).text().trim().replace('\n','\n ')		
						[value, name, effect...] = attribute.split(' ')

						traitLine.attributes.push
							name: name.split('\n')[0]
							effect: effect.join(' ').replace(/[^\w\s-]/g,'')
							value: value.replace('+','')

				type = if traitLineIndex <= 2 then 'minor' else 'major'

				traitLine.traits[type] = [] unless traitLine.traits[type]
				traitLine.traits[type].push
									name: $name.text()
									type: $name.prev().text()
									description: $description.text().replace '\n', ''									

				if traitLineIndex is numOfTraitsPerLine - 1
					traitLines.push traitLine if traitLine.name

			console.log util.inspect traitLines, false, null, true
			@emit name: profession, traitLines: traitLines 
	output: (profession) ->
		dbProvider.save 'traits', profession[0]

@class = Traits
@job = new Traits 
			timeout:1200
			jsdom: true
			auto_retry: true