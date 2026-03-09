--Since many things in this game were generated using screen resolution at first, there was need to add global constant
--values of standard width and height of the screen so that game didn't mess up object generation on different resolutions.

local Config = {}
Config.STANDARD_WIDTH = 1920
Config.STANDARD_HEIGHT = 1080
Config.GLOBAL_SIZE_MULTIPLIER = math.floor(Config.STANDARD_HEIGHT / 200)

Config.TILE_SIZE = 24
return Config