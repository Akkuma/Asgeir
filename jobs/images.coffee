nodeio = require 'node.io'
util = require 'util'
fs = require 'fs'
_s = require 'underscore.string'
require 'coffee-script'
require '../profession/professions'

skillIconsCategory = 'Category:%s_skill_icons'
rootLink = "http://wiki.guildwars2.com"
baseWikiLink = "#{rootLink}/wiki/"

imageDirectory = "#{__dirname}/#{require('../config').imageDirectory}"
fs.mkdir imageDirectory, (err) ->
	fs.mkdir "#{imageDirectory}/#{profession}" for profession in professions

class Images extends nodeio.JobClass
	input: professions
	run: (profession) ->
		skillIconsLink = util.format skillIconsCategory, _s.capitalize(profession)
		professionSkillIconsLink = baseWikiLink + skillIconsLink
		
		await @getHtml professionSkillIconsLink, defer err, $
		images = $('#bodyContent').find('.gallery img[src$=".png"]').toArray()
		$nextPage  = $("a[title='#{skillIconsLink.replace /_/g, ' '}']")

		if $nextPage.length
			await @getHtml rootLink + $nextPage[0].href, defer err, _$
			images = images.concat _$('#bodyContent').find('.gallery img[src$=".png"]').toArray()
		
		imgs = []
		await
			for img, i in images
				getImageData.call @, img, defer imgs[i]

		await
			for image, i in imgs
				fs.writeFile "#{imageDirectory}/#{profession}/#{image.name}", 
					image.data, 'binary', ->
		
		@debug util.inspect (image.name for image in imgs), false, null, true
		@debug imgs.length
		@emit "Compeleted #{profession}"

getImageData = (img, cb) ->
	src = img.src.replace('thumb/', '')
	src = src[0..src.indexOf('.png') + 3]	

	@get rootLink + src, (err, data) ->
		if err
			console.log rootLink + src
			console.log err
			@exit err
		cb 
			name: img.alt.replace /\s\(.*[^.png]/, ''
			data: data

@class = Images
@options = 
	jsdom: true
	encoding: 'binary'
	timeout: 1200
	#max: 5
	auto_retry: true
	wait: 5
@job = new Images @options