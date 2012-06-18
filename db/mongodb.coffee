require 'coffee-script'

config = require('../config')
db = require('mongojs').connect(config.db.name)

upsert = (collection, data) ->
	id = data._id
	delete data._id

	find = if id then _id: id else {}

	db.collection(collection).update(find, {$set: data}, {upsert:true})

traits = (profession) ->
	upsert 'professions',	_id: profession.name, traits: profession.traitLines
skills = (profession) ->
	upsert 'professions',	_id: profession.name, skills: profession.skills
sigils = (sigils) ->
	upsert 'sigils', sigils
runes =	(runes) ->
	upsert 'runes', runes

module.exports =
	save: (job, data) =>
		#before
		#around
		@[job] data
		#after