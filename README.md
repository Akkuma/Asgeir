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
	- Minor and Major are typed
	- Attributes associated with a trait line are available
		- Name, such as Compassion
		- Effect, such as Healing 
		- Value, the improvement 1 point in a trait rewards (either 1% or 10)
- All weapon skills for every profession are pulled down and organized
	- Organized first by how many hands required, bothhands, mainhand, offhand
	- Name of weapon lives underneath
	- The weapon contains all skills associated with it ordered by slot
	- A weapon can contain additional sets of skills or properties
		- Thief and Warriors have their profession mechanic tied to a particular weapon
		- Elementalists have different sets of skills based on their current attunement

What needs to be done?
----------------------
- Wire up output abstraction to allow plug and play with various databases
- Use the generic parsing built out to get slot, downed, etc. working
- Evaluate if the current json structure is appropriate
- Evaluate if the current code needs more refactoring
- Improve resiliency against wiki changes

Example JSON structure
----------------------
Weapon skills currently have a structure like this for Warriors:

In normal JavaScript
	skills = {
		weapon: {
			mainhand: {
				Sword: {
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

In CoffeeScript
	skills =
		weapon:
			mainhand:
				Sword:
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
				