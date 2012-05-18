nodeio = require 'node.io'
util = require 'util'
require 'coffee-script'
require './profession/professions'

class Traits extends nodeio.JobClass
	input: professions
	run: (profession) -> 
		traitLink = 'http://wiki.guildwars2.com/wiki/List_of_%s_traits'
		traitLines = []

		@getHtml util.format(traitLink, profession), (err, $) => 
			$rows = $ '#traits tr:not(:first-child)' 
			$trait = $rows.first().find('td:first')
			numOfTraitsPerLine = $trait.attr('rowspan')

			traitLine = {}
			$rows.each (k,v) ->
				$row = $(v)
				$description = $row.children().last()
				$name = $description.prev()
				traitLineIndex = k % numOfTraitsPerLine

				if traitLineIndex is 0
					$traitLineCell = $row.find('td:first')					
					numOfTraitsPerLine = $traitLineCell.attr('rowspan')

					traitLine = 
						name: $traitLineCell.children('b').text()
						traits: []
						attributes: []

					$attributes = $traitLineCell.find('p').not(':first');
					i = -1
					while ++i isnt 2
						attribute = $attributes.eq(i).text().trim().split(' ')
						traitLine.attributes.push
							name: attribute[1]
							value: attribute[0].replace('+','')


				if traitLineIndex <= 2
					type = $name.prev().text()					
				else	
					type = 'Major'

				traitLine.traits.push
									name: $name.text()
									type: type
									description: $description.text().replace '\n', ''									

				if traitLineIndex is numOfTraitsPerLine - 1
					traitLines.push traitLine if traitLine.name

			@emit name: profession, traitLines: traitLines 
			###util.inspect traitLines, false, null, true###
	output: (profession) ->

@class = Traits
@job = new Traits 
			timeout:1200
			jsdom: true