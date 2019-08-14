return PlaceObj('ModDef', {
	'title', "Indome Triboelectric Scrubber",
	'description', "Allows Triboelectric Scrubbers to be built inside a dome.\n\nWhen under a dome, the scrubber covers the entire inside of the dome, and the range is fixed to the size of the dome. Reverts to vanilla behaviour if the dome is opened.\n\nPermission is granted to update this mod to support the latest version of the game if I'm not around to do it myself.",
	'last_changes', "Initial Version",
	'dependencies', {
		PlaceObj('ModDependency', {
			'id', "mrudat_AllowBuildingInDome",
			'title', "Allow Building In Dome",
		}),
	},
	'id', "mrudat_IndomeTriboelectricScrubber",
	'pops_desktop_uuid', "58abdc76-cbf2-4801-bcde-56453c1c2c76",
	'pops_any_uuid', "977d46c0-90ca-465e-8551-af0574ca1c88",
	'author', "mrudat",
	'version', 3,
	'lua_revision', 233360,
	'saved_with_revision', 245618,
	'code', {
		"Code/IndomeTriboelectricScrubber.lua",
	},
	'saved', 1565734865,
})
