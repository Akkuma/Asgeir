Asgeir
======

What is Asgeir?
---------------
A Guild Wars 2 Wiki parser/scraper for Node.js that transforms profession information into a json structure allowing the creation of databases or other tools. 

Why?
----
I'm working on my own Guild Wars 2 site and saw this as an opportunity to leverage the community, contribute to it, and improve my own coding skills. The Guild Wars 2 wiki should become the central knowledge hub and not some third party site. If the wiki becomes the de facto standard everyone who uses this wiki parser and the users of sites/tools created against this wiki parser will greatly benefit. If the wiki contains all the information we could ever want, why not use the data to create a database or any other tool?

What does it currently do?
--------------------------
- All traits for every profession are pulled down and organized
	- Contain type (Minor/Major) and tier (Adept/Master/Grandmaster)
	- Attributes associated with a trait line are available
		- Name, such as Compassion
		- Effect, such as Healing 
		- Value, the improvement 1 point in a trait rewards (either 1% or 10)
- All weapon skills for every profession are pulled down and organized
	- Organized by name of weapon -> weapon "hands" -> skills associated with that hand ordered by slot
	- A weapon can contain additional sets of skills or properties
		- Thief and Warriors have their profession mechanic tied to a particular weapon
			- Organized by name of weapon -> mechanic -> skill
		- Elementalists have different sets of skills based on their current attunement
			- Organized by name of weapon -> "hands" -> attunement -> skills
- All .png images are saved onto disc and organized
	- /images/[profession]/[imageName].png
	- Can customize image directory path
- All superior sigils are pulled down
	- Organized by type (weapon switch/on crit/etc.)
	- PvE only sigils are ignored
- All runes are pulled down and organized
	- Organized by primary cumulative attribute

What needs to be done?
----------------------
- ~~Wire up output abstraction to allow plug and play with various databases~~
- ~~Use the generic parsing built out to get slot, downed, etc. working~~
- Resolve inconsistencies between json structures
- Evaluate if the current json structure is appropriate
	- Particularly in context of MongoDB (arrays of objects vs object of objects)
- Evaluate if the current code needs more refactoring
- Improve resiliency against wiki changes
- Provide transformations to the data where applicable
	- For example, having runes also organized by secondary attribute

Example JSON structure
----------------------
Weapon skills currently have a structure like this for Warriors:

In JavaScript
```javascript
skills = {
	weapon: {
		Sword: {
			mainhand: {
				skills: [
					{
						name: '',
						description: '',							
						recharge: 0,
						chain: [
							{
								name: '',
								description: '',
								recharge: 0
							}
						]
					}
				],
				burstSkill: {
					name: '',
					description: '',
					recharge: 10
				}
			}
		}
	}
}
```
In CoffeeScript
```javascript
skills =
	weapon:
		Sword:
			mainHand:
				skills: [
					{
						name: '',
						description: ''							
						recharge: 0
						chain: [
							{
								name: ''
								description: ''
								recharge: 0
							}
						]
					}
				]
				burstSkill:
					name: ''
					description: ''
					recharge: 10		
```